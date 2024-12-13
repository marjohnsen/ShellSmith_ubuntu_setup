#!/usr/bin/env bash

create_temp_theme() {
  local original="$1"
  local semantic="$2"
  local color="$3"
  local temp_file
  temp_file=$(mktemp /tmp/rofi_theme.XXXXXX.rasi)
  sed "s/ *$semantic:[^;]*;/    $semantic:    $color;/" "$original" >"$temp_file"
  echo "$temp_file"
}

ROFI_THEME="$(dirname "$0")/../style.rasi"
RED_ROFI_THEME=$(create_temp_theme "$ROFI_THEME" "accent" "#FF000040")
GRAY_ROFI_THEME=$(create_temp_theme "$ROFI_THEME" "accent" "#CCBBAA40")

dotdotdot() {
  local dots=("   " ".  " ".. " "...")
  local i=0
  while :; do
    notify-send -t 500 "Scanning for wireless networks${dots[i]}"
    sleep 0.5
    i=$(((i + 1) % 4))
  done
}

get_wifi_list() {
  local rescan="$1"
  local wifi_list
  wifi_list=$(nmcli --fields "SECURITY,SSID,BARS,FREQ,CHAN,IN-USE" device wifi list --rescan "${rescan}" 2>/dev/null)

  if [[ $? -ne 0 || -z "$wifi_list" ]]; then
    notify-send "Error" "Failed to fetch Wi-Fi list. Ensure Wi-Fi is enabled and try again."
    exit 1
  fi

  echo "$wifi_list" | awk -F'  +' '
  BEGIN {
      cmd="nmcli connection show | awk \047NR>1 {print $1}\047";
      while ((cmd | getline saved) > 0) saved_networks[saved] = 1;
      close(cmd);
  }
  NR>1 {
      security=$1;
      ssid=$2;
      bars=$3;
      freq = ($4 ~ /^2/) ? "2.4" : (($4 ~ /^5/) ? "5.0" : "NA");
      chan = $5;
      freq_chan = freq "#" chan; 
      in_use=$6;

      if (in_use ~ /\*/) {
          icon="";
          priority=NR;
      } else if (ssid in saved_networks) {
          icon="󰓎";
          priority=NR + 10000;
      } else {
          icon="";
          priority=NR + 100000;
      }

      printf "%d|%-1s|%-20s|%-7s|%4s\n", priority, icon, ssid, freq_chan, bars;
  }
  ' | sort -t"|" -k1,1n | awk -F"|" '
  {
      printf "%-1s %-20s %-7s %4s\n", $2, $3, $4, $5;
  }'
}

show_menu() {
  local message="$1"
  local options="$2"
  local theme="$3"
  echo -e "$options" | rofi -dmenu -i -p "$message" -theme "$theme"
}

extract_ssid() {
  echo "$1" | sed -E 's/^.{3}//;s/  \(.*$//'
}

extract_saved_networks() {
  nmcli --fields NAME,TYPE connection show | grep wifi | awk '{ $NF=""; print $0 }' | sed 's/ $//'
}

toggle_wifi() {
  local action="$1"
  if [[ "$action" == "󰨙 Enable Wi-Fi" ]]; then
    nmcli radio wifi on
  elif [[ "$action" == "󰔡 Disable Wi-Fi" ]]; then
    nmcli radio wifi off
  fi
}

connect_to_saved_network() {
  local ssid="$1"
  nmcli connection up id "$ssid" &&
    notify-send "Connected to \"$ssid\"" ||
    notify-send "Failed to connect to saved network: \"$ssid\""
}

disconnect_saved_network() {
  local ssid="$1"
  nmcli connection down id "$ssid" &&
    notify-send "Disconnected from \"$ssid\"" ||
    notify-send "Failed to disconnect network: \"$ssid\""
}

connect_to_new_network() {
  local ssid="$1"
  local is_secure="$2"
  local wifi_password=""

  if [[ "$is_secure" =~  ]]; then
    wifi_password=$(rofi -dmenu -p "Password: " -theme "$ROFI_THEME")
    [[ -z "$wifi_password" ]] && notify-send "No password entered for \"$ssid\"" && exit
    nmcli device wifi connect "$ssid" password "$wifi_password" &&
      notify-send "Connected to \"$ssid\"" ||
      notify-send "Failed to connect to \"$ssid\". Check password."
  else
    nmcli device wifi connect "$ssid" &&
      notify-send "Connected to \"$ssid\"" ||
      notify-send "Failed to connect to \"$ssid\". Check signal."
  fi
}

delete_saved_network_menu() {
  local saved_networks
  local delete_selected
  local confirmation

  saved_networks=$(extract_saved_networks)
  delete_selected=$(show_menu "Delete SSID: " "$saved_networks" "$RED_ROFI_THEME")

  if [[ -n "$delete_selected" ]]; then
    confirmation=$(show_menu "Confirm delete \"$delete_selected\"?" "Yes\nNo" "$RED_ROFI_THEME")

    if [[ "$confirmation" == "Yes" ]]; then
      nmcli connection delete id "$delete_selected" &&
        notify-send "Deleted network \"$delete_selected\"" ||
        notify-send "Failed to delete network \"$delete_selected\""
    else
      notify-send "Deletion cancelled"
    fi
  else
    notify-send "No network selected for deletion"
  fi
}

select_option_menu() {
  local rescan=$1
  local spinner_pid
  local wifi_status
  local wifi_list
  local wifi_option
  local delete_option
  local theme
  local selected

  dotdotdot &
  spinner_pid=$!

  wifi_status=$(nmcli -fields WIFI g)
  wifi_list=$(get_wifi_list "${rescan}")

  kill "$spinner_pid" 2>/dev/null

  wifi_option="$([[ "$wifi_status" =~ "disabled" ]] && echo "󰨙 Enable Wi-Fi" || echo "󰔡 Disable Wi-Fi")"
  delete_option="󰚃 Delete Wifi"

  theme=$([[ "$wifi_option" =~ "󰔡" ]] && echo "$ROFI_THEME" || echo "$GRAY_ROFI_THEME")

  selected=$(show_menu "SSID: " "$wifi_option\n$delete_option\n$wifi_list" "$theme")

  echo -e "$selected"
}

main() {
  local rescan=$1
  SELECTED=$(select_option_menu "$rescan")
  SSID=$(extract_ssid "$SELECTED")

  case "$SELECTED" in
  "") exit 1 ;;
  *󰓎*) connect_to_saved_network "$SSID" ;;
  **) disconnect_saved_network "$SSID" && main "yes" ;;
  *󰚃*) delete_saved_network_menu && main "no" ;;
  ** | **) connect_to_new_network_menu "$SSID" "$SELECTED" ;;
  *󰔡* | *󰨙*) toggle_wifi "$SELECTED" && main "yes" ;;
  *) notify-send "Error: state of ${SELECTED} is not known" && main "yes" ;;
  esac
}

main "$1"

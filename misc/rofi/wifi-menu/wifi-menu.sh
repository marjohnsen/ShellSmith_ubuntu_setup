#!/usr/bin/env bash

ROFI_THEME="$(dirname "$0")/../style.rasi"

dotdotdot() {
  local dots=(". " ".. " "... ")
  local i=0
  while :; do
    notify-send -t 1005 "Scanning for wireless networks${dots[i]}"
    sleep 1
    i=$(((i + 1) % 3))
  done
}

get_wifi_list() {
  local wifi_list
  wifi_list=$(nmcli --fields "SECURITY,SSID,BARS,FREQ,IN-USE" device wifi list --rescan yes 2>/dev/null)

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
      freq = ($4 ~ /^2/) ? "2.4 GHz" : (($4 ~ /^5/) ? "5.0 GHz" : "NA");
      in_use=$5;

      if (in_use ~ /\*/) icon="";
      else if (ssid in saved_networks) icon="󰓎";
      else if (security ~ /WPA|WEP/) icon="";
      else icon="";

      printf "%-5s %-30s %10s %10s\n", icon, ssid, freq, bars;
  }'
}

show_menu() {
  local options="$1"
  echo -e "$options" | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: " -theme "$ROFI_THEME"
}

extract_ssid() {
  echo "$1" | sed -E 's/^.{3}//;s/  \(.*$//'
}

toggle_wifi() {
  local action="$1"
  if [[ "$action" == "󰨙 Enable Wi-Fi" ]]; then
    nmcli radio wifi on
    notify-send "Wi-Fi Enabled"
  elif [[ "$action" == "󰔡 Disable Wi-Fi" ]]; then
    nmcli radio wifi off
    notify-send "Wi-Fi Disabled"
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
    notify-send "Failed to connect to dosconnect network: \"$ssid\""
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

main() {
  dotdotdot &
  spinner_pid=$!

  WIFI_STATUS=$(nmcli -fields WIFI g)
  WIFI_LIST=$(get_wifi_list)

  kill "$spinner_pid" 2>/dev/null

  WIFI_TOGGLE=$([[ "$WIFI_STATUS" =~ "disabled" ]] && echo "󰨙  Enable Wi-Fi" || echo "󰔡  Disable Wi-Fi")
  SELECTED=$(show_menu "$WIFI_TOGGLE\n$WIFI_LIST")
  SSID=$(extract_ssid "$SELECTED")

  if [[ -z "$SELECTED" ]]; then
    notify-send "None selected" && exit 1
  elif [[ "$SELECTED" =~ 󰓎 ]]; then
    connect_to_saved_network "$SSID"
  elif [[ "$SELECTED" =~  ]]; then
    disconnect_saved_network "$SSID"
  elif [[ "$SELECTED" =~  ]] || [[ "$SELECTED" =~  ]]; then
    connect_to_new_network "$SSID" "$SELECTED"
  elif [[ "$SELECTED" =~ 󰔡 ]] || [[ "$SELECTED" =~ 󰨙 ]]; then
    toggle_wifi "$SELECTED"
  else
    notify-send "Error: state of ${SELECTED} is not known" && exit 1
  fi
}

main "$@"

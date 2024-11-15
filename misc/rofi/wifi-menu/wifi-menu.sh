#!/usr/bin/env bash

# Get the directory of the current script
script_dir="$(dirname "$0")"

# Get Wi-Fi status and list available networks
wifi_status=$(nmcli -fields WIFI g)
wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list --rescan no | sed '1d; s/  */ /g; s/WPA*.?\S/ /g; s/^--/ /g; s/  //g; /--/d')

# Toggle Wi-Fi option based on current status
toggle="󰖪  Disable Wi-Fi"
[[ "$wifi_status" =~ "disabled" ]] && toggle="󰖩  Enable Wi-Fi"

# Display options in rofi menu and capture selection
chosen_network=$(echo -e "$toggle\n$wifi_list" | uniq -u | rofi -dmenu -i -selected-row 1 -p "Wi-Fi SSID: " -theme "$script_dir/wifi-menu.rasi")
[[ -z "$chosen_network" ]] && exit

# Extract selected SSID (ignores icons like  or )
chosen_id=$(echo "${chosen_network:3}" | xargs)

# Enable or disable Wi-Fi based on selection
if [[ "$chosen_network" == "󰖩  Enable Wi-Fi" ]]; then
  nmcli radio wifi on && exit
elif [[ "$chosen_network" == "󰖪  Disable Wi-Fi" ]]; then
  nmcli radio wifi off && exit
fi

# Prepare to connect to selected network
success_message="You are now connected to the Wi-Fi network \"$chosen_id\"."
saved_connections=$(nmcli -g NAME connection | grep -w "$chosen_id")

if [[ "$saved_connections" == "$chosen_id" ]]; then
  nmcli connection up id "$chosen_id" && notify-send "Connection Established" "$success_message"
else
  # Prompt for password if network is secured
  if [[ "$chosen_network" =~ "" ]]; then
    wifi_password=$(rofi -dmenu -p "Password: ")
    [[ -z "$wifi_password" ]] && exit
  fi
  nmcli device wifi connect "$chosen_id" password "$wifi_password" && notify-send "Connection Established" "$success_message"
fi

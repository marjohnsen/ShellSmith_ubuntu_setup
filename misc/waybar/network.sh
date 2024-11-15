#!/bin/bash

wifi_interface=$(ip link | awk -F: '$2 ~ /wlp/ {print $2; exit}' | xargs)
ethernet_interface=$(ip link | awk -F: '$2 ~ /enp/ {print $2; exit}' | xargs)

get_ip() { ip address show "$1" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1; }
get_network_name() { iwgetid -r; }

# Check Ethernet connection
if [[ -n "$ethernet_interface" ]] && [[ $(cat "/sys/class/net/$ethernet_interface/operstate" 2>/dev/null) == "up" ]]; then
  ip_address=$(get_ip "$ethernet_interface")
  icon="󰈀&#8196;"
  tooltip="󰈀 Wired Network\r󰩟 IP: ${ip_address}"
  echo '{"text":"'"$icon"'", "tooltip":"'"$tooltip"'"}'
  exit 0
fi

# Check Wi-Fi connection
if [[ -n "$wifi_interface" ]] && [[ $(cat "/sys/class/net/$wifi_interface/operstate" 2>/dev/null) == "up" ]]; then
  network_name=$(get_network_name)
  ip_address=$(get_ip "$wifi_interface")
  signal_strength=$(grep "$wifi_interface" /proc/net/wireless | awk '{ print int($3 * 100 / 70) }')

  # Choose icon based on signal strength
  if ((signal_strength > 75)); then
    icon="󰤨&#8196;"
  elif ((signal_strength > 50)); then
    icon="󰤥&#8196;"
  elif ((signal_strength > 25)); then
    icon="󰤢&#8196;"
  else
    icon="󰤟&#8196;"
  fi

  tooltip="󰛳 ${network_name}\r󰩟 IP: ${ip_address}\r󰤨 Signal: ${signal_strength}%"
  echo '{"text":"'"$icon"'", "tooltip":"'"$tooltip"'"}'
  exit 0
fi

# Fallback when no network is connected
icon="󰈂&#8196;"
tooltip="󰈂\rNo Network\r󰩟 IP: $(get_ip lo)"
echo '{"text":"'"$icon"'", "tooltip":"'"$tooltip"'"}'

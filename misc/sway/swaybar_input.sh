#!/bin/bash

SPACE=$'\u2009'

DATE=$(date +'%Y-%m-%d %H:%M:%S')

CPU=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%d%%", usage}')

MEM=$(free -h | awk '/^Mem:/ {printf "%.1f/%.1fGB", $3, $2}')

DISK=$(df -h / | awk 'NR==2 {printf "%s/%s", $3, $2}')

WIFI_SSID=$(iwgetid -r 2>/dev/null || echo "No WiFi")
if grep -q ":" /proc/net/wireless; then
  SIGNAL=$(awk 'NR==3 {print int($3 * 100 / 70)}' /proc/net/wireless)
  IP=$(hostname -I | awk '{print $1}' || echo "No IP")
  WIFI="${SIGNAL:-0}%${SPACE}-${SPACE}$WIFI_SSID${SPACE}-${SPACE}$IP"
else
  WIFI="No WiFi"
fi

BATTERY_PATH=$(upower -e | grep BAT)
if [ -n "$BATTERY_PATH" ]; then
  BATTERY_STATE=$(upower -i "$BATTERY_PATH" 2>/dev/null | grep state | awk '{print $2}')
  BATTERY_PERCENT=$(upower -i "$BATTERY_PATH" 2>/dev/null | grep percentage | awk '{print $2}')

  if [ "$BATTERY_STATE" == "charging" ]; then
    BAT="󰂄 $BATTERY_PERCENT"
  else
    BAT="󰁹 $BATTERY_PERCENT"
  fi
else
  BAT="No Battery"
fi

VOL_RAW=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]*%' | head -n1)
MUTED_STATE=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -o "yes")
if [ "$MUTED_STATE" == "yes" ]; then
  VOL="󰖁 Muted"
else
  VOL="󰕾 $VOL_RAW"
fi

echo " ${SPACE}$CPU |  ${SPACE}${SPACE}$MEM |  $DISK |   $WIFI | $BAT | $VOL |  ${SPACE}$DATE"

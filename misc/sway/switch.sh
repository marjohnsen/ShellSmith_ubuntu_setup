#!/bin/bash

STATE_FILE="/tmp/swayfx_mode"

if [ -n "$1" ]; then
  SWAYFX_MODE=$1
  FROM="console"
else
  SWAYFX_MODE=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
  FROM="file"
fi

if [ "$SWAYFX_MODE" -eq 0 ]; then
  SWAYFX_MODE=1
  cp ~/.config/sway/scripts/bar0 ~/.config/sway/bar
  swaymsg reload
  # swaymsg '[app_id=".*"] border pixel 2'
  # swaymsg 'for_window [app_id=".*"] border pixel 2'
  swaymsg 'corner_radius 0'
  swaymsg 'gaps inner current set 0'
  swaymsg '[app_id=".*"] opacity 1'
  swaymsg 'for_window [app_id=".*"] opacity 1'
elif [ "$SWAYFX_MODE" -eq 1 ]; then
  SWAYFX_MODE=0
  cp ~/.config/sway/scripts/bar1 ~/.config/sway/bar
  swaymsg reload
  # swaymsg '[app_id=".*"] border none'
  # swaymsg 'for_window [app_id=".*"] border none'
  swaymsg 'corner_radius 10'
  swaymsg 'gaps inner current set 10'
  swaymsg '[app_id=".*"] opacity 0.9'
  swaymsg 'for_window [app_id=".*"] opacity 0.9'
else
  echo "Expected state to be either 1 or 0, but got ${SWAYFX_MODE} from ${FROM}"
fi

echo "$SWAYFX_MODE" >"$STATE_FILE"

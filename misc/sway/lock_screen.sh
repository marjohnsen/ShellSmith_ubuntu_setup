#!/bin/bash

tmp_dir="/tmp/lockscreen"
mkdir -p "$tmp_dir"

# Generate pixelated lock screens for all active monitors
for output in $(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name'); do
  screenshot="$tmp_dir/${output}_screenshot.png"
  pixelated_screenshot="$tmp_dir/${output}_pixelated.png"

  grim -o "$output" "$screenshot"
  convert "$screenshot" -scale 5% -scale 2000% "$pixelated_screenshot"
done

# Build the swaylock command with all monitor images
swaylock_cmd="swaylock"
for output in $(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name'); do
  pixelated_screenshot="$tmp_dir/${output}_pixelated.png"
  swaylock_cmd+=" -i $output:$pixelated_screenshot"
done

# Lock the screen with all monitors at once
eval "$swaylock_cmd"

# Clean up temporary files
rm -rf "$tmp_dir"

#!/bin/bash

screenshot="/tmp/lockscreen.png"
pixelated_screenshot="/tmp/pixelated_lockscreen.png"

grim "$screenshot"

convert "$screenshot" -scale 10% -scale 1000% "$pixelated_screenshot"

swaylock -i "$pixelated_screenshot"

rm "$screenshot" "$pixelated_screenshot"

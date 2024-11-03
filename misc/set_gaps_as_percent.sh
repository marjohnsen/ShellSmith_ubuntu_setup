#!/bin/bash

set_gap() {
  local direction=$1
  local percentage=$2
  local gap_size
  gap_size=$(awk -v p="$percentage" -v w="$SCREEN_WIDTH" 'BEGIN {print w * p / 100}')
  i3-msg gaps "$direction" all set "$gap_size"
}

SCREEN_WIDTH=$(xrandr | awk '/\*/ {split($1, res, "x"); print res[1]}')

while getopts "l:r:t:b:i:o:" opt; do
  case "$opt" in
  l) set_gap left "$OPTARG" ;;
  r) set_gap right "$OPTARG" ;;
  t) set_gap top "$OPTARG" ;;
  b) set_gap bottom "$OPTARG" ;;
  i) set_gap inner "$OPTARG" ;;
  o) set_gap outer "$OPTARG" ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  :)
    echo "Option -$OPTARG requires an argument." >&2
    exit 1
    ;;
  esac
done

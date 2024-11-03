img=/tmp/i3lock.png

scrot -o $img

convert $img -scale 10% -scale 1000% $img

pkill -x picom

i3lock --nofork -u -i $img

picom -b --config "$HOME/.config/picom/picom.conf" &

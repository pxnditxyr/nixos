#!/usr/bin/env bash
# Script para cambiar entre ventanas con rofi

windows=$(hyprctl clients -j | jq -r '.[] | "\(.workspace.id):\(.class):\(.title)"')

if [ -z "$windows" ]; then
    notify-send "No windows found"
    exit 0
fi

selected=$(echo "$windows" | rofi -dmenu -i -p "Switch to window" | cut -d: -f3)

if [ -n "$selected" ]; then
    hyprctl dispatch focuswindow "title:$selected"
fi

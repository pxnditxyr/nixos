#!/usr/bin/env bash
# Rofi Calculator Script using qalc

# Get calculation from rofi
calc=$(rofi -dmenu -p "Calculator" -theme-str 'window {width: 50%;}')

# Exit if nothing was entered
if [ -z "$calc" ]; then
    exit 0
fi

# Use qalc (Qalculate!) to calculate
result=$(qalc "$calc" 2>/dev/null | tail -n 1)

# Show result and copy to clipboard if selected
action=$(echo -e "Copy to clipboard\nNew calculation" | rofi -dmenu -p "Result: $result")

if [ "$action" = "Copy to clipboard" ]; then
    echo -n "$result" | wl-copy
    notify-send "Calculator" "Result copied: $result"
elif [ "$action" = "New calculation" ]; then
    exec ~/.config/hypr/scripts/rofi-calc.sh
fi

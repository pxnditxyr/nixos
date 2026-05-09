#!/usr/bin/env bash
# Script para cambiar wallpapers dinámicamente

WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper directory not found" "Create $WALLPAPER_DIR and add images"
    exit 1
fi

# Seleccionar wallpaper con rofi
selected=$(ls "$WALLPAPER_DIR" | rofi -dmenu -i -p "Select wallpaper")

if [ -n "$selected" ]; then
    # Cambiar wallpaper con hyprpaper
    hyprctl hyprpaper preload "$WALLPAPER_DIR/$selected"
    hyprctl hyprpaper wallpaper ",$WALLPAPER_DIR/$selected"
    
    notify-send -i "$WALLPAPER_DIR/$selected" "Wallpaper changed" "$selected"
fi

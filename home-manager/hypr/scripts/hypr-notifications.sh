#!/usr/bin/env bash
# Script para mostrar notificaciones de sistema con estilo

case "$1" in
    volume)
        volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
        muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -o "MUTED")
        
        if [ "$muted" = "MUTED" ]; then
            notify-send -a "volume" -u low -i audio-volume-muted "Volume Muted" -h int:value:0
        else
            notify-send -a "volume" -u low -i audio-volume-high "Volume" -h int:value:$volume
        fi
        ;;
    brightness)
        brightness=$(brightnessctl g)
        max=$(brightnessctl m)
        percent=$((brightness * 100 / max))
        notify-send -a "brightness" -u low -i display-brightness "Brightness" -h int:value:$percent
        ;;
    *)
        echo "Usage: $0 {volume|brightness}"
        exit 1
        ;;
esac

#!/usr/bin/env bash

monitors=$(cat /tmp/monitors.json)

# Disable the monitors
IFS=$'\n'
for monitor_id in $(echo "$monitors" | jq -r '.[].id'); do
    monitor=$(echo "$monitors" | jq ".[] | select(.id == $monitor_id)")

    name=$(echo "$monitor" | jq -r '.name')

    if [[ "$name" = "DP-3" ]]; then continue; fi

    width=$(echo "$monitor" | jq -r '.width')
    height=$(echo "$monitor" | jq -r '.height')
    refresh_rate=$(echo "$monitor" | jq -r '.refreshRate')
    x=$(echo "$monitor" | jq -r '.x')
    y=$(echo "$monitor" | jq -r '.y')

    scale=$(echo "$monitor" | jq -r '.scale')

    hyprctl keyword monitor "$name, ${width}x${height}@$refresh_rate, ${x}x${y}, $scale"
done

sleep 5

pkill waybar
hyprctl keyword exec "waybar"

swww kill
hyprctl keyword exec "swww-daemon"

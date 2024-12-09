#!/usr/bin/env bash

monitors=$(hyprctl monitors all -j)

echo "$monitors" >/tmp/monitors.json

# Disable the monitors
IFS=$'\n'
for name in $(echo "$monitors" | jq -r '.[].name'); do
    if [[ "$name" = "DP-3" ]]; then continue; fi

    hyprctl keyword monitor "$name,disable"
done

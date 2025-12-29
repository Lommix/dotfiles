#!/bin/bash

# Get all Bluetooth devices with battery info
devices=$(upower -e | grep -E 'keyboard|mouse|headset|gaming_input')

output=""
tooltip=""

for device in $devices; do
    # Get device info
    info=$(upower -i "$device")

    # Extract percentage
    percentage=$(echo "$info" | grep -oP 'percentage:\s+\K\d+')

    # Skip if no percentage available
    if [ -z "$percentage" ]; then
        continue
    fi

    # Extract model
    model=$(echo "$info" | grep -oP 'model:\s+\K.*')

    # Determine icon based on device type
    if echo "$device" | grep -q "mouse"; then
        icon="󰍽"
    elif echo "$device" | grep -q "keyboard"; then
        icon="󰌌"
    elif echo "$device" | grep -q "headset"; then
        icon="󰋋"
    else
        icon="󰂯"
    fi

    # Add to output
    if [ -n "$output" ]; then
        output="$output  "
    fi
    output="$output$percentage% $icon"

    # Add to tooltip
    if [ -n "$tooltip" ]; then
        tooltip="$tooltip\n"
    fi
    tooltip="$tooltip$model: $percentage%"
done

# If no devices found, output nothing
if [ -z "$output" ]; then
    echo '{"text": "", "tooltip": "No Bluetooth devices"}'
else
    # Output JSON for Waybar
    echo "{\"text\": \"$output\", \"tooltip\": \"$tooltip\"}"
fi

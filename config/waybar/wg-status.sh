#!/bin/bash

vpn_icon_connected="󰴳"
vpn_icon_disconnected="󰦜"

# Check WireGuard status
# If wg show returns nothing -> down
# If wg show returns permission error -> up (interface exists but needs sudo to see details)
wg_output=$(wg show 2>&1)

if [ -z "$wg_output" ]; then
    # No output means no WireGuard interfaces
    echo "{\"text\":\"$vpn_icon_disconnected\",\"tooltip\":\"WireGuard disconnected\",\"class\":\"disconnected\"}"
else
    # Any output (including permission error) means WireGuard is up
    echo "{\"text\":\"$vpn_icon_connected\",\"tooltip\":\"WireGuard connected\",\"class\":\"connected\"}"
fi
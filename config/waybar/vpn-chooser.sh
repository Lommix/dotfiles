#!/bin/bash

# # Checking internet connectivity
if ping -c 1 8.8.8.8 &>/dev/null; then
	vpn_connected=false
	current_interface="init"

	iface_status=$(ip link show "tun0" 2>/dev/null | grep -oP "(?<=state )\w+")
	if [ "$iface_status" = "UP" ] || [ "$iface_status" = "UNKNOWN" ]; then
		vpn_connected=true
		vpn_ip=$(ip -4 addr show "tun0" | grep -oP "(?<=inet\s)\d+(\.\d+){3}")
		current_interface="$iface"
		break
	fi

	if [ "$vpn_connected" = true ]; then
		kitty -e sudo pkill openvpn
	else
		sudo openvpn "$(find ~/.openvpn -type f | rofi -dmenu -p 'VPN> ')"
	fi
fi

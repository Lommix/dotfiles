#!/bin/bash

# VyprVpn
# add openvpn to NOPW
# lommix ALL=(ALL) NOPASSWD: /usr/bin/openvpn
# DL pub CA:
# sudo wget https://support.vyprvpn.com/hc/article_attachments/360059510571/ca.vyprvpn.com.crt

input_file="$1"
output_dir="$HOME/.openvpn"

mkdir -p "$output_dir"

if [[ ! -f "$input_file" ]]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

while IFS= read -r line; do
    out_file="$output_dir/${line}.ovpn"
    cat <<EOF > "$out_file"
client
dev tun
proto udp
remote $line 1194
resolv-retry infinite
nobind
persist-key
persist-tun
cipher BF-CBC
data-ciphers AES-256-GCM:AES-128-GCM:BF-CBC
comp-lzo
providers legacy default
ca /etc/openvpn/ca.vyprvpn.com.crt
auth-user-pass /home/lommix/.vypr_login.txt
redirect-gateway def1 ipv6
EOF
done < "$input_file"

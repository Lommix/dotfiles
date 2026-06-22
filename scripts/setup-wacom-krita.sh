#!/bin/sh
set -eu

install -d /etc/keyd
tee /etc/keyd/wacom-intuos-m.conf >/dev/null <<'EOF'
[ids]
056a:0375:1d060662

[main]
f13 = f13
f14 = f14
f15 = f15
f16 = f16
EOF

keyd check /etc/keyd/wacom-intuos-m.conf
systemctl enable --now keyd
keyd reload

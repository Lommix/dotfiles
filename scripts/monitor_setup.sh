#!/bin/sh
xrandr --output DisplayPort-0 --primary --mode 2560x1440 --pos 0x0 --rotate normal --output DisplayPort-1 --mode 3440x1440 --rate 164.90 --pos 2560x0 --rotate normal --output DisplayPort-2 --off --output HDMI-A-0 --mode 1920x1080 --pos 6000x0 --rotate normal
setxkbmap -layout "de,fr" -variant "nodeadkeys,basic"

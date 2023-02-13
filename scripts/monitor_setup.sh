#!/bin/sh
xrandr --output DisplayPort-0 --mode 2560x1440 --pos 1920x0 --rotate normal --output DisplayPort-1 --mode 1920x1080 --pos 7920x0 --rotate normal --output DisplayPort-2 --primary --mode 3440x1440 -r 164 --pos 4480x0 --rotate normal --output HDMI-A-0 --mode 1920x1080 --pos 0x0 --rotate normal
setxkbmap -layout "de,fr" -variant "nodeadkeys,basic"

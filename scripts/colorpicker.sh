#!/bin/bash
grim -g "$(slurp -b 00000000 -p)" -t png - | convert - -format '%[pixel:p{0,0}]' txt:- |grep -oP "#[0-9A-F]{6}" | wl-copy

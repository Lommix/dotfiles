#!/bin/bash

DIR="$HOME/.config/waybar"
CONFIG_FILES="$DIR/config $DIR/style.css"

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/waybar-watch.lock"
flock -n 9 || exit 0

bar_pid=""
trap 'kill "$bar_pid" 2>/dev/null' EXIT TERM INT

while true; do
    waybar &
    bar_pid=$!

    while kill -0 "$bar_pid" 2>/dev/null; do
        inotifywait -q -t 2 -e create,modify,close_write $CONFIG_FILES >/dev/null 2>&1 && break
    done

    kill "$bar_pid" 2>/dev/null
    wait "$bar_pid" 2>/dev/null
    bar_pid=""
done

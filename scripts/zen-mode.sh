#!/bin/bash
# Toggle focus/zen: keep only biggest monitor, disable the rest.
# Hyprland lua config: must use `hyprctl eval`, not keyword.

STATE="${XDG_RUNTIME_DIR:-/tmp}/hypr-zen-mode"

if [[ -f "$STATE" ]]; then
  rm -f "$STATE"
  hyprctl reload
  exit 0
fi

mapfile -t mons < <(hyprctl monitors -j | jq -r '.[] | "\(.name) \(.width) \(.height)"')
[[ ${#mons[@]} -le 1 ]] && exit 0

biggest=""
biggest_px=0
others=()

for line in "${mons[@]}"; do
  read -r name w h <<<"$line"
  px=$((w * h))
  if ((px > biggest_px)); then
    [[ -n "$biggest" ]] && others+=("$biggest")
    biggest=$name
    biggest_px=$px
  else
    others+=("$name")
  fi
done

for mon in "${others[@]}"; do
  hyprctl eval "hl.monitor({ output = \"${mon}\", disabled = true })"
done

hyprctl eval "hl.dispatch(hl.dsp.focus({ monitor = \"${biggest}\" }))"
touch "$STATE"

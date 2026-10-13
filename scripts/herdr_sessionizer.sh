#!/usr/bin/env bash
set -euo pipefail

herdr_bin=${HERDR_BIN_PATH:-herdr}

roots=(
    ~/Documents
    ~/Projects
    ~/Projects/rust
    ~/Projects/godot
    ~/Projects/zig
    ~/Projects/vendor
    ~/Projects/js
    ~/Projects/python
    ~/Projects/go
    ~/Projects/work
    ~/Projects/work/ultra
    ~/Documents/Projects
    ~/Documents/obsidian
)

if [[ $# -eq 1 ]]; then
    selected=$1
else
    scannable=()
    for root in "${roots[@]}"; do
        if [[ -d $root ]]; then
            scannable+=("$root")
        fi
    done

    if [[ ${#scannable[@]} -eq 0 ]]; then
        exit 0
    fi

    selected=$(find "${scannable[@]}" -mindepth 1 -maxdepth 1 -type d -not -path '*/\.*' | fzf || true)
fi

if [[ -z $selected ]]; then
    exit 0
fi

label=$(basename "$selected" | tr . _)

existing=$("$herdr_bin" workspace list | jq -r --arg label "$label" 'first(.result.workspaces[] | select(.label == $label) | .workspace_id) // empty')

if [[ -n $existing ]]; then
    "$herdr_bin" workspace focus "$existing"
else
    "$herdr_bin" workspace create --cwd "$selected" --label "$label" --focus
fi

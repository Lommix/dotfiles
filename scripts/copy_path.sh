#!/bin/bash

selected_file=$(find ~ -type f | fzf)
if [ -n "$selected_file" ]; then
	wl-copy $selected_file
fi

#!/bin/bash

timestamp=$(date +%Y%m%d%H%M%S)
output_file="${timestamp}.mp4"

if [ -n "$1" ]; then
	output_file="$1"
fi

wf-recorder -f ${output_file}

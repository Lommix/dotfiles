#!/bin/bash

if [ -z "$1" ]; then
	echo "needs name"
	exit 0
fi

output_file="/home/lommix/Documents/Screenrecs/$1.mp4"
wf-recorder --geometry="$(slurp)" -f ${output_file}

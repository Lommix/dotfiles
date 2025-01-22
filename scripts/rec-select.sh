#!/bin/bash

if [ -z "$1" ]; then
	echo "needs name"
	exit 0
fi

output_file="/home/lommix/Screenrecs/$1.mp4"

if [ "$2" = "." ]; then
	output_file="./${1}.mp4"
fi


wf-recorder --geometry="$(slurp)" -f ${output_file}

#!/bin/bash

timestamp=$(date +%Y_%m_%d_%S)
output_file="/home/lommix/Documents/Screenrecs/${timestamp}.mp4"

wf-recorder -f ${output_file} -g "$(slurp)"

# if -g arg for gif
arg=$1
if [ "$arg" == "-g" ]; then
	output_gif="${timestamp}.gif"
	ffmpeg -i ${output_file} -vf "fps=10,scale=640:-1:flags=lanczos" -c:v gif -f gif ${output_gif}
fi

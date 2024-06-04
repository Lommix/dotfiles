#!/bin/bash

# Super nice screen recorder
timestamp=$(date +%Y%m%d%H%M%S)
output_file="${timestamp}.mp4"
output_file=$(echo $output_file | tr -d \'\" )


wf-recorder -f ${output_file} -g "$(slurp)"

# if -g arg for gif
arg=$1
if [ "$arg" == "-g" ]; then
	output_gif="${timestamp}.gif"
	ffmpeg -i ${output_file} -vf "fps=10,scale=640:-1:flags=lanczos" -c:v gif -f gif ${output_gif}
fi

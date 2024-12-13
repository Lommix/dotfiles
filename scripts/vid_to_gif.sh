#!/bin/bash

if [ -z "$1" ]; then
	echo "No video file provided."  exit 1
fi

input=$1
output="${input%.*}.gif"
fps=30
width=640

if [ -n "$2" ]; then
	fps=$2
fi

ffmpeg -i $input -vf "palettegen" palette.png
ffmpeg -i $input -i palette.png -filter_complex "fps=$fps,scale=$width:-1:flags=lanczos[x];[x][1:v]paletteuse" $output

rm palette.png

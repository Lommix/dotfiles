#!/bin/bash

# Quick format a video for
# posting

if [ -z "$1" ]; then
	echo "no video"
	exit 0
fi

input=$1
name="prep_$(basename "$input")"

bitrate="4M"

if [ -n "$2" ]; then
	bitrate=$2
fi

ffmpeg -i $1 -c:v libx264 -profile:v main -level 4.0 \
-preset medium -vf "scale=trunc(oh*a/2)*2:720,format=yuv420p" \
-c:a aac -ac 2 -ar 44100 -b:a 128k -movflags +faststart -r 30 \
-g 60 -maxrate 5M -bufsize 10M -b:v $bitrate -shortest -f mp4 \
$name

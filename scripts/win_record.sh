#!/bin/bash

if [ $# -eq 0 ]
  then
	echo "No arguments supplied"
	exit 1
fi

output_type=$1

if [ "$output_type" != "mp4" ] && [ "$output_type" != "webm" ] && [ "$output_type" != "gif" ]
  then
	echo "Invalid output type"
	exit 1
fi

# Get window ID
window_id=$(xdotool selectwindow)
# Get window width
width=$(xwininfo -id $window_id | grep 'Width:' | awk '{print $2}')
# Get window height
height=$(xwininfo -id $window_id | grep 'Height:' | awk '{print $2}')
# round even
window_height=$((height / 2 * 2))
window_width=$((width / 2 * 2))
# Get window X coordinate
window_x=$(xwininfo -id $window_id | grep 'Absolute upper-left X:' | awk '{print $4}')
# Get window Y coordinate
window_y=$(xwininfo -id $window_id | grep 'Absolute upper-left Y:' | awk '{print $4}')
# Get window name
window_name=$(xwininfo -id $window_id | grep 'xwininfo: Window id:' | awk '{print $5}' | tr -d \')
# Get current timestamp
timestamp=$(date +%Y%m%d%H%M%S)
# Set output file name
output_file="${window_name}_${timestamp}.${output_type}"
output_file=$(echo $output_file | tr -d \'\" )

# Run ffmpeg command
ffmpeg \
-video_size ${window_width}x${window_height} \
-framerate 30 \
-f x11grab \
-i :0.0+${window_x},${window_y} \
-vcodec libx264 \
-preset ultrafast \
-crf 18 \
-pix_fmt yuv420p $output_file

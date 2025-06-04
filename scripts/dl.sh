#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <input_file>"
  exit 1
fi

input_file="$1"

while IFS= read -r url;
do
    yt-dlp --extract-audio --audio-format mp3 --restrict-filenames --output "%(title)s.%(ext)s" "$url"
done < "$input_file"

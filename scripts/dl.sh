#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: $0 <input_url>"
  exit 1
fi

output="~/Music/%(title)s.%(ext)s"

if [ -n "$2" ]; then
    mkdir ~/Music/$2 &> /dev/null
    output="~/Music/$2/%(title)s.%(ext)s"
fi

yt-dlp --extract-audio --audio-format mp3 --embed-thumbnail --embed-metadata --restrict-filenames --output "$output" "$1"

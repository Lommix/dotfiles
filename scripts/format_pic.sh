#!/bin/bash

# Quick format a pic for posting

if [ -z "$1" ]; then
	echo "no pic"
	exit 0
fi

input=$1
name="prep_$(basename "$input")"

convert $1 -resize 1080x1080\>  $name

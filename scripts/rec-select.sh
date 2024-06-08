#!/bin/bash

timestamp=$(date +%Y_%m_%d_%S)
output_file="/home/lommix/Documents/Screenrecs/${timestamp}.mp4"

wf-recorder --geometry="$(slurp)" -f ${output_file}

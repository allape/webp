#!/usr/bin/env bash

tmp_folder=".tmp.rescuing"

mkdir -p "$tmp_folder"

input_file=$1

if [ -z "$input_file" ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

echo "Input file: $input_file"

total_frames=$(webpmux -tolerantly -info "$input_file" | tail -n +6 | wc -l)
echo "Total frames: $total_frames"

for ((i=1; i<=total_frames; i++)); do
    webpmux -tolerantly -get frame $i -o "$tmp_folder/frame_$i.webp" "$input_file"
done

output_file="rescued.$input_file"

IFS=' ' read -r -a durations <<< "$(webpmux -tolerantly -info "$input_file" | tail -n +6 | awk '{printf "%s ", $7} END {print ""}')"

command="webpmux -tolerantly"

for ((i=1; i<=total_frames; i++)); do
    command+=" -frame $tmp_folder/frame_$i.webp +${durations[i-1]}"
done

command+=" -loop 0 -o $output_file"

echo "Output file: $output_file"
echo "Command: $command"

eval "$command"

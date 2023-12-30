#!/bin/bash

# Include scripts
source ./logging.zsh

# Script entry (run as early as possible after include)
SCRIPTENTRY

BASE_INPUT="$1"
BASE_OUTPUT="$2"
BASE_VIDEO_OUTPUT="$BASE_OUTPUT/Videos"

#############################################################
# Functions
#############################################################

function convert_video {
  ENTRY $FUNCNAME
  input=$1
  filename="${input##*/}"
  file_base="${filename%.*}"
  output_file="${file_base}.mp4"
  folder_path="${input%/*}"
  folder_name="${folder_path##*/}"
  folder_name_underscore="${folder_name// /_}"
  output="$BASE_OUTPUT/$folder_name_underscore/$output_file"

  INFO "Converting $input to $output"
    if ! command -v ffmpeg &> /dev/null; then
    ERROR "ffmpeg could not be found"
    return
  fi
  ffmpeg -n -vsync 2 -i "$input" "$output"
  SUCCESS "Converted $input to $output"
  EXIT $FUNCNAME
}

function process_folder {
  SECONDS=0
  ENTRY $FUNCNAME
  input=$1
  INFO "Processing input folder $input"
  folder_name="${input##*/}"
  folder_name_underscore="${folder_name// /_}"
  output_folder="$BASE_OUTPUT/$folder_name_underscore"
  output_video="$BASE_VIDEO_OUTPUT/$folder_name_underscore.mp4"
  file_count=$(ls -1 "$input" | wc -l | tr -d ' ')

  # if joined video file is already created, skip
  if [ -f "$output_video" ]; then
    WARN "Output video $output_video already exists. Skipping..."
    return
  fi

  # create temp output folder if it doesn't exist
  if [ ! -d "$output_folder" ]; then
    INFO "Creating temp output folder $output_folder"
    mkdir "$output_folder"
  else
    WARN "Output folder $output_folder already exists"
  fi

  # skip info.dvr, I don't know what this is
  for file in "$input"/*; do
    if [[ "$file" == *"info.dvr"* ]]; then
      WARN "Skipping info file $file"
    else
      INFO "Processing file $file"
      convert_video "$file"
    fi
  done

  INFO "Concatenating files to $output_video"
  list_file="$output_folder/list.txt"
  if [[ -f "$list_file" ]]; then
    rm "$list_file"
  fi
  for file in "$output_folder"/*; do
    echo "file '$file'" >>"$list_file"
  done

  ffmpeg -n -f concat -safe 0 -i "$list_file" -c copy "$output_video"

  if [ -f "$output_video" ]; then
    INFO "Removing temp folder $output_folder"
    rm -rf "$output_folder"
  fi

  total_seconds=$SECONDS
  minutes=$(((total_seconds % 3600) / 60))
  seconds=$((total_seconds % 60))
  SUCCESS "Finished processing $file_count files in $minutes minute(s) $seconds second(s)"
  EXIT $FUNCNAME
}

#############################################################
# Main script
#############################################################
folder_count=0
total_folders=$(ls -1 "$BASE_INPUT" | wc -l | tr -d ' ')

INFO "~~~~~~ Start video script - Processing $total_folders folders - $(date)"

for folder in "$BASE_INPUT"/*; do
  folder_count=$((folder_count + 1))
  process_folder "$folder"
  PROGRESS "$folder_count" "$total_folders"
done

INFO "~~~~~~ Finish video script - $(date)"
SCRIPTEXIT

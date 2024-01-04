#!/bin/bash

# Logging needs if I recall corectly

# Set the path to the directory where you want to move the files with missing audio
target_dir=/path/to/target

# Set the path to the log file
log_file=/path/to/log

# Set the threshold for detecting muted audio or zero volume
threshold=0.03

# Loop through all files in the current directory that have a .mp4 ext
for file in *.mp4
do
    # Check if the file has no audio stream
    if ffprobe "$file" 2>&1 | tee -a "$log_file" | grep -q "Stream #0:1: Audio: none"; then
        # Move the file to the target directory
        mv "$file" "$target_dir"
        echo "Moved $file to $target_dir (missing audio)" | tee -a "$log_file"
    else
        # Get the audio volume
        volume=$(timeout 5 ffprobe -v error -show_entries frame=pkt_pts_time,pkt_duration_time,frame_tags=lavfi.astats.Overall.RMS_level -of default=noprint_wrappers=1:nokey=1 "$file" | awk '{if(NR>5){print $0}}' | sort -rn | head -1)
        # Check if the audio is muted or has zero volume
        if (( $(echo "$volume < $threshold" | bc -l) )); then
            # Move the file to the target directory
            mv -v "$file" "$target_dir"
            echo "Moved $file to $target_dir (muted audio or zero volume)" | tee -a "$log_file"
        fi
    fi
done

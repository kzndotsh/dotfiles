#!/bin/bash

# Define the directory containing the images to sort
DIR=/path/to/images

# Define the maximum dimensions for each category
BIG_MAX_WIDTH=1024
BIG_MAX_HEIGHT=1024
SMALL_MAX_WIDTH=512
SMALL_MAX_HEIGHT=512

# Loop through each image in the directory
for IMG in $DIR/*.{jpg,jpeg,png,gif,JPG,JPEG,PNG,GIF}; do

  # Get the dimensions of the image using ImageMagick's identify command
  DIMENSIONS=$(identify -format "%wx%h" "$IMG")

  # Extract the width and height from the dimensions
  WIDTH=$(echo "$DIMENSIONS" | cut -d'x' -f1)
  HEIGHT=$(echo "$DIMENSIONS" | cut -d'x' -f2)

  # Determine the appropriate directory based on the dimensions
  if (( WIDTH > BIG_MAX_WIDTH || HEIGHT > BIG_MAX_HEIGHT )); then
    DIR_NAME="big"
  elif (( WIDTH > SMALL_MAX_WIDTH || HEIGHT > SMALL_MAX_HEIGHT )); then
    DIR_NAME="small"
  else
    DIR_NAME="tiny"
  fi

  # Create the appropriate subdirectory if it doesn't exist
  mkdir -vp "$DIR/$DIR_NAME"

  # Move the image to the appropriate subdirectory
  mv -nv "$IMG" "$DIR/$DIR_NAME/"

done

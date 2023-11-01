#!/bin/bash

# Set the directory containing your wallpapers
WALLPAPER_DIR="/home/kaizen/walls"

# Get a random wallpaper from the directory
RANDOM_WALLPAPER=$(ls $WALLPAPER_DIR | shuf -n 1)

# Set the wallpaper using feh
feh --bg-fill --no-fehbg "$WALLPAPER_DIR/$RANDOM_WALLPAPER"

# Save the current wallpaper path to a file for later deletion
echo "$WALLPAPER_DIR/$RANDOM_WALLPAPER" > ~/.current_wallpaper

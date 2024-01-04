#!/bin/bash

# Read the current wallpaper path from the saved file
CURRENT_WALLPAPER=$(cat ~/.current_wallpaper)

# Delete the current wallpaper file
rm "$CURRENT_WALLPAPER"

# Run the wallpaper changer script to set a new wallpaper
/home/kaizen/scripts/wallpaper-changer.sh

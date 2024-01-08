#!/bin/bash

# alpha-organize.sh

#####################
# The following script is to help organize a directory of directories into alphabetical groups based on their initial characters
# This is useful for organizing a large directory of movies into alphabetical groups for easier importing into Radarr
#####################

# Set the source directory - this is the directory that contains the movies to be organized, this directory should contain only directories
# Don't forget the trailing slash!
SOURCE_DIR="/src"

# Set the destination directory - this is the directory that will contain the alphabetized groups of movies
# Don't forget the trailing slash!
DEST_DIR="/dest"

# Set additional flags for rclone commands - for example, to run a dry run, set the following:
FLAGS="--progress --verbose --transfers=64 --checkers=64 --fast-list --tpslimit=12 --tpslimit-burst=50 --no-update-modtime --no-traverse"

# Get the list of directories in the source directory
DIRS=$(rclone lsf --dirs-only "$SOURCE_DIR")

# Loop through the directories
# Each line should be a directory name, some of which may contain spaces/special characters

while IFS= read -r DIR; do
    # Log the directory name
    echo "Directory: $DIR"

    # Get the first character of the directory name
    FIRST_CHAR=${DIR:0:1}

    # Log the first character
    echo "First character: $FIRST_CHAR"

    # Find the corresponding letter group for the directory
    GROUP=""
    case "$FIRST_CHAR" in
    [0-9]) GROUP="0-9" ;;
    [A-Z]) GROUP="$FIRST_CHAR" ;;
    [a-z]) GROUP="${FIRST_CHAR^}" ;; # Convert first character to uppercase
    *) GROUP="Default" ;;
    esac

    # Log the group
    echo "Group: $GROUP"

    # Move the entire source directory to the destination directory
    # Use the --delete-empty-src-dirs flag to delete the source directory if it is empty after the move
    rclone move --delete-empty-src-dirs "$SOURCE_DIR$DIR" "$DEST_DIR$GROUP/$DIR" $FLAGS
done <<<"$DIRS"

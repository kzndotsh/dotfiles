#!/bin/bash

# Define directories for different file types
IMAGES_DIR="$HOME/downloads/images"
VIDEOS_DIR="$HOME/downloads/videos"
ARCHIVES_DIR="$HOME/downloads/archives"
TORRENTS_DIR="$HOME/downloads/torrents"
DOCUMENTS_DIR="$HOME/downloads/documents"
MISC_DIR="$HOME/downloads/misc"

# Create directories if they don't exist
mkdir -p "$IMAGES_DIR" "$VIDEOS_DIR" "$ARCHIVES_DIR" "$TORRENTS_DIR" "$DOCUMENTS_DIR" "$MISC_DIR"

# File extensions for different file types
IMAGE_EXTENSIONS=("jpg" "jpeg" "png" "gif" "bmp" "svg" "webp")
VIDEO_EXTENSIONS=("mp4" "avi" "mkv" "mov" "wmv" "flv" "webm" "3gp")
ARCHIVE_EXTENSIONS=("zip" "tar" "gz" "rar" "7z" "xz")
TORRENT_EXTENSIONS=("torrent")
DOCUMENT_EXTENSIONS=("txt" "pdf" "doc" "docx" "xls" "xlsx" "ppt" "pptx" "odt" "ods" "odp")

# Move files to appropriate directories based on their extensions
for file in "$HOME"/downloads/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        extension="${filename##*.}"
        lowercase_extension="${extension,,}"

        if [[ " ${IMAGE_EXTENSIONS[@]} " =~ " ${lowercase_extension} " ]]; then
            mv "$file" "$IMAGES_DIR/$filename"
        elif [[ " ${VIDEO_EXTENSIONS[@]} " =~ " ${lowercase_extension} " ]]; then
            mv "$file" "$VIDEOS_DIR/$filename"
        elif [[ " ${ARCHIVE_EXTENSIONS[@]} " =~ " ${lowercase_extension} " ]]; then
            mv "$file" "$ARCHIVES_DIR/$filename"
        elif [[ " ${TORRENT_EXTENSIONS[@]} " =~ " ${lowercase_extension} " ]]; then
            mv "$file" "$TORRENTS_DIR/$filename"
        elif [[ " ${DOCUMENT_EXTENSIONS[@]} " =~ " ${lowercase_extension} " ]]; then
            mv "$file" "$DOCUMENTS_DIR/$filename"
        else
            mv "$file" "$MISC_DIR/$filename"
        fi
    fi
done

echo "Organizing complete!"

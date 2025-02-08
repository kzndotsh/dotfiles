#!/bin/bash

extract_files() {
    local directory=$1
    # Iterate over each file in the directory
    for file in "$directory"/*; do
        if [[ -d "$file" ]]; then
            # If it's a directory, call this function recursively
            extract_files "$file"
        elif [[ -f "$file" ]]; then
            # Check the file type and extract accordingly
            case "$file" in
                *.tar.bz2) tar xvjf "$file" -C "$directory" && extract_files "${file%.tar.bz2}" ;;
                *.tar.gz)  tar xvzf "$file" -C "$directory" && extract_files "${file%.tar.gz}" ;;
                *.bz2)     bunzip2 "$file" ;;
                *.rar)     unrar x "$file" "$directory" ;;
                *.gz)      gunzip "$file" ;;
                *.tar)     tar xvf "$file" -C "$directory" && extract_files "${file%.tar}" ;;
                *.tbz2)    tar xvjf "$file" -C "$directory" && extract_files "${file%.tbz2}" ;;
                *.tgz)     tar xvzf "$file" -C "$directory" && extract_files "${file%.tgz}" ;;
                *.zip)     unzip "$file" -d "$directory" && extract_files "${file%.zip}" ;;
                *.Z)       uncompress "$file" ;;
                *.7z)      7z x "$file" -o"$directory" ;;
                # *)         echo "Don't know how to extract '$file'..." ;;
            esac
        fi
    done
}

# Start extraction from the current directory
extract_files "."

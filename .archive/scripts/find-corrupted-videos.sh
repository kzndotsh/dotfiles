#!/bin/bash
root="."
filecount=$(find "$root" -type f | wc -l)
find "$root" -iname \*.avi -o -iname \*.mp4 -o -iname \*.mkv -o -iname \*.m4v -o -iname \*.wmv -o -iname \*.mov -o -iname \*.mpg -o -iname \*.mpeg -o -iname \*.wma -o -iname \*.asf -o -iname \*.asx -o -iname \*.rm -o -iname \*.3gp -o -iname \*.0gm | {
    processed=0
    corrupt=0
    while read -r pathname
    do
        if ! ffprobe -v quiet -show_error -i "$pathname"
        then
            let ++corrupt
            printf 'rm %q\n' "$pathname" >>deletions
        fi
        echo -n ' ' $((++processed)) / $filecount, $corrupt $'bad\r'
    done
}

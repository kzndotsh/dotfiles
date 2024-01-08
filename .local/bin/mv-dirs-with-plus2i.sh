#!/bin/sh

## Move dirs containing more than 1 file to a specific dir

## initialize newdir from 1st argument (or default: OOOO3_MORE_THAN_ONE)
newdir="${1:-dupes}"

## set your complete path from 2nd arg (or '.' by default)
cmpltpath="${2:-.}"

## now create a temporary file to hold count dirname pairs
tmpfile=$(mktemp)

for dir in *; do    ## write count and dirname pairs to temporary file
    [ -d "$dir" ] && echo "$(find "$dir" -type f | wc -l) $dir" >> "$tmpfile"
done

## now create the directory to move to using cmpltpath, exit on failure
mkdir -p "$cmpltpath/$newdir" || exit 1

## read count and dirname from tmpfile & move if count > 1
while read -r count dir || [ -n "$dir" ]; do
    ## if count=2 then move 
    if [ "$count" -gt 1 ]; then 
        ## move to dir 
        mv -v "$dir" "$cmpltpath/$newdir" 
    fi
done < "$tmpfile"

rm "$tmpfile"   ## tidy up and remove tmpfile (or set trap after mktemp)

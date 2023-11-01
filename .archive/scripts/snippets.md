# Snippets

### Unrar recursively and preserve
`find . -name '*.rar' -execdir unrar e {} \;`

### Delete empty directories in the current path recusrively
`find . -empty -type d -delete`

### Move all files recursively to parent
`find . -mindepth 2 -type f -print -exec mv {} . \;`

### Make dir for every specified file type, example: mkv
```
for x in *.mkv; do            
  mkdir "${x%.*}" && mv "$x" "${x%.*}"
done
```

### Sort all sub dirs into a group dir based on their first character
```
for f in *; do
    firstChar="${f:0:1}";
    mkdir -p -- "$firstChar";
    mv -v -- "$f" "$firstChar";
done
```
### Group files contained in a dir by a specific number count into sub dirs, example: 5
`n=0; for f in *; do d="subdir$((n++ / 5))"; mkdir -p "$d"; mv -- "$f" "$d/$f"; done`

### Batch embed english subtitles to mkv, replace ass w/ srt if srt, make sure "output/" exists
`for i in *.mkv; do ffmpeg -i "$i" -f ass -i "${i%.*}.ass" -metadata:s:s:0 language=eng -metadata:s:s:0 title="sxales restyled" -disposition:s:0 default -c:v copy -c:a copy output/"${i%.}"; done`

### Batch fix missing md5 in FLAC between subcategories
`for dir in *; do (cd "$dir" && flac -f8 *.flac); done`

### Organize files in root dir by file type into sub dirs, not 100% perfect
`find . -iname '*?.?*' -type f -exec bash -c 'EXT="${0##*.}"; mkdir -p "$PWD/${EXT}_dir"; mv -nv --target-directory="$PWD/${EXT}_dir" "$0"' {} \;`

### Make torrent file for every subdir in dir
`for i in *; do mktorrent -v -p -a https:Announceurl/announce -o DestinationDir/"$i".torrent "$i";done`


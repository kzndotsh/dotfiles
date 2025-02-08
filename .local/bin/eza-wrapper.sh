#!/bin/bash

## Change following to '0' for output to be like ls and '1' for eza features
# Don't list implied . and .. by default with -a
dot=0
# Show human readable file sizes by default
hru=1
# Show file sizes in decimal (1KB=1000 bytes) as opposed to binary units (1KiB=1024 bytes)
meb=0
# Don't show group column
fgp=0
# Don't show hardlinks column
lnk=0
# Show file git status automatically (can cause a slight delay in large repo trees)
git=1
# Show icons
ico=1
# Show column headers
hed=1
# Group directories first in long listing by default
gpd=1
# Colour always even when piping (can be disabled with -N switch when not wanted)
col=1

help() {
    cat << EOF
  ${0##*/} options:
   -a  all
   -A  almost all
   -1  one file per line
   -x  list by lines, not columns
   -l  long listing format
   -G  display entries as a grid *
   -k  bytes
   -h  human readable file sizes
   -F  classify
   -R  recurse
   -r  reverse
   -d  don't list directory contents
   -D  directories only *
   -P  group directories first *
   -I  ignore [GLOBS]
   -i  show inodes
   -o  show octal permissions *
   -N  no colour *
   -S  sort by file size
   -t  sort by modified time
   -u  sort by accessed time
   -c  sort by created time *
   -X  sort by extension
   -M  time style [iso|long-iso|full-iso|relative] *
   -T  tree *
   -L  level [DEPTH] *
   -s  file system blocks
   -g  don't show/show file git status *
   -O  don't show/show icons *
   -n  ignore .gitignore files *
   -b  file sizes in binary/decimal (--si in ls)
   -Z  show each file's security context
   -@  extended attributes and sizes *

    * not used in ls
EOF
    exit
}

[[ $* =~ --help ]] && help

eza_opts=()

while getopts ':aAbtucSI:rkhnsXL:M:PNg1lFGRdDioOTxZ@' arg; do
  case $arg in
    a) (( dot == 1 )) && eza_opts+=(-a) || eza_opts+=(-a -a) ;;
    A) eza_opts+=(-a) ;;
    t) eza_opts+=(-s modified); ((++rev)) ;;
    u) eza_opts+=(-us accessed); ((++rev)) ;;
    c) eza_opts+=(-Us created); ((++rev)) ;;
    S) eza_opts+=(-s size); ((++rev)) ;;
    I) eza_opts+=(--ignore-glob="${OPTARG}") ;;
    r) ((++rev)) ;;
    k) ((--hru)) ;;
    h) ((++hru)) ;;
    n) eza_opts+=(--git-ignore) ;;
    s) eza_opts+=(-S) ;;
    X) eza_opts+=(-s extension) ;;
    L) eza_opts+=(--level="${OPTARG}") ;;
    o) eza_opts+=(--octal-permissions) ;;
    M) eza_opts+=(--time-style="${OPTARG}") ;;
    P) ((++gpd)) ;;
    N) ((++nco)) ;;
    g) ((++git)) ;;
    O) ((++ico)) ;;
    b) ((--meb)) ;;
    1|l|F|G|R|d|D|i|T|x|Z|@) eza_opts+=(-"$arg") ;;
    :) printf "%s: -%s switch requires a value\n" "${0##*/}" "${OPTARG}" >&2; exit 1
       ;;
    *) printf "Error: %s\n       --help for help\n" "${0##*/}" >&2; exit 1
       ;;
  esac
done

shift "$((OPTIND - 1))"

(( rev == 1 )) && eza_opts+=(-r)
(( fgp == 0 )) && eza_opts+=(-g)
(( lnk == 0 )) && eza_opts+=(-H)
(( hru <= 0 )) && eza_opts+=(-B)
(( hed == 1 )) && eza_opts+=(-h)
(( meb == 0 && hru > 0 )) && eza_opts+=(-b)
(( col == 0 )) && eza_opts+=(--color=always) || eza_opts+=(--color=auto)
(( nco == 1 )) && eza_opts+=(--color=never)
(( gpd >= 1 )) && eza_opts+=(--group-directories-first)
(( ico == 1 )) && eza_opts+=(--icons)
(( git == 1 )) && \
  [[ $(git -C ${*:-.} rev-parse --is-inside-work-tree) == true ]] 2>/dev/null && eza_opts+=(--git)

eza "${eza_opts[@]}" "$@"

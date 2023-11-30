#!/bin/sh

set -e

cd "$(dirname "$0")"

[ -f "config" ] && rm -f config

for conf in *.conf
do
    padding=$(((54 - ${#conf}) / 2))
    printf "\n################################################################\n##%*s%s%*s##\n################################################################\n" $padding "" "Begin ${conf}" $padding "" >> config
    cat -- "${conf}" >> config
    printf "################################################################\n##%*s%s%*s##\n################################################################\n\n" $padding "" "Finish ${conf}" $padding "" >> config
done

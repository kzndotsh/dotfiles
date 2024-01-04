#!/bin/bash
lowlevel=($(hwdetect --show-modules | awk -F: '{gsub("-","_"); print $2}'))

for mod in $(awk '{print $1}' /proc/modules); do
    if ! grep -q "$mod" <(printf '%s\n' "${lowlevel[@]}"); then
        printf '%s\n' "$mod";
    fi
done

#!/bin/bash
modules=($(awk '{print $1}' /proc/modules))

for hw in $(hwdetect --show-modules | awk -F: '{gsub("-","_"); print $2}'); do
    if ! grep -q "$hw" <(printf '%s\n' "${modules[@]}"); then
        printf '%s\n' "$hw";
    fi
done

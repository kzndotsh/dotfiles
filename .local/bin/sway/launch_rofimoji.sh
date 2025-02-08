#!/bin/bash

# Determine which output is currently active (where the mouse pointer is). 🤔
MONITOR_ID=XWAYLAND$(swaymsg -t get_outputs | jq '[.[].focused] | index(true)')

# Let's pick our emojis! 🎉
rofimoji --action type --skin-tone light  \
    --selector-args="-theme solarized -font 'Inter 14' -monitor ${MONITOR_ID}"

#!/bin/bash 

# Save this script into set_colors.sh, make this file executable and run it: 
# 
# $ chmod +x set_colors.sh 
# $ ./set_colors.sh 
# 
# Alternatively copy lines below directly into your shell. 

gconftool-2 -s -t string /apps/guake/style/background/color '#1a1a1b1b2626'
gconftool-2 -s -t string /apps/guake/style/font/color '#c0c0cacaf5f5'
gconftool-2 -s -t string /apps/guake/style/font/palette '#151516161e1e:#f7f776768e8e:#9e9ecece6a6a:#e0e0afaf6868:#7a7aa2a2f7f7:#bbbb9a9af7f7:#7d7dcfcfffff:#a9a9b1b1d6d6:#414148486868:#f7f776768e8e:#9e9ecece6a6a:#e0e0afaf6868:#7a7aa2a2f7f7:#bbbb9a9af7f7:#7d7dcfcfffff:#c0c0cacaf5f5'

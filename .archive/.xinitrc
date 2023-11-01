#!/bin/bash

# .xinitrc

# Disable automatic monitor power saving screensaver
xset dpms 0 0 0
xset s off
xset -dpms

# Ensure the display is set correctly
xrandr --output DisplayPort-2 --mode 1920x1080 --rate 165

# User-specific X resources and keymap settings
userresources="$XDG_CONFIG_HOME/X11/xresources"
usermodmap="$XDG_CONFIG_HOME/X11/xmodmap"

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# System-wide X resources and keymap settings
sysresources="/etc/X11/xinit/.Xresources"
sysmodmap="/etc/X11/xinit/.Xmodmap"

if [ -f "$sysresources" ]; then
    xrdb -merge "$sysresources"
fi

if [ -f "$sysmodmap" ]; then
    xmodmap "$sysmodmap"
fi

# Source systemd user environment variables
export $(run-parts /usr/lib/systemd/user-environment-generators | sed '/:$/d; /^$/d' | xargs)

source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh

# Ensure the XDG_RUNTIME_DIR is set
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-$USER}"
mkdir -p "$XDG_RUNTIME_DIR"

# Create or ensure the keychain directory exists
KEYCHAIN_DIR="$XDG_RUNTIME_DIR/keychain"
mkdir -p "$KEYCHAIN_DIR"

# Add SSH keys to keychain
keychain --dir "$KEYCHAIN_DIR" ~/.ssh/id_ed25519 || {
    echo "Error adding id_ed25519 to keychain" >&2
    exit 1
}

keychain --dir "$KEYCHAIN_DIR" ~/.ssh/id_rsa || {
    echo "Error adding id_rsa to keychain" >&2
    exit 1
}

# Source keychain files if they exist
if [ -f "$KEYCHAIN_DIR/$HOSTNAME-sh" ]; then
    source "$KEYCHAIN_DIR/$HOSTNAME-sh" 2>/dev/null
fi

if [ -f "$KEYCHAIN_DIR/$HOSTNAME-sh-gpg" ]; then
    source "$KEYCHAIN_DIR/$HOSTNAME-sh-gpg" 2>/dev/null
fi

# Set SSH_ASKPASS
export SSH_ASKPASS="/usr/lib/ssh/x11-ssh-askpass"

# Start your window manager or desktop environment
if [ -x /usr/bin/i3 ]; then
    exec i3
fi

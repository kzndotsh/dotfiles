#!/bin/sh
# ~/.xinitrc

userresources=$XDG_CONFIG_HOME/X11/xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

export $(run-parts /usr/lib/systemd/user-environment-generators | sed '/:$/d; /^$/d' | xargs)

source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh

mkdir -p "$XDG_RUNTIME_DIR/keychain"
keychain --dir "$XDG_RUNTIME_DIR"/keychain ~/.ssh/id_ed25519
keychain --dir "$XDG_RUNTIME_DIR"/keychain ~/.ssh/id_rsa
[ -f "$XDG_RUNTIME_DIR"/keychain/$HOSTNAME-sh ] && . "$XDG_RUNTIME_DIR"/keychain/$HOSTNAME-sh 2>/dev/null
[ -f "$XDG_RUNTIME_DIR"/keychain/$HOSTNAME-sh-gpg ] && . "$XDG_RUNTIME_DIR"/keychain/$HOSTNAME-sh-gpg 2>/dev/null

export SSH_ASKPASS="/usr/lib/ssh/x11-ssh-askpass"

if [ -f /usr/bin/i3 ]; then
    exec i3
fi

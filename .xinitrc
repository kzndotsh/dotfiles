#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f "$sysresources" ]; then
    xrdb -merge "$sysresources"
fi

if [ -f "$sysmodmap" ]; then
    xmodmap "$sysmodmap"
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh
# exec /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
#eval $(/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh) &
#export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO SSH_AUTH_SOCK &

# # see https://unix.stackexchange.com/a/295652/332452
# source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh
# # see https://wiki.archlinux.org/title/GNOME/Keyring#xinitrc
# eval $(/usr/bin/gnome-keyring-daemon --start)
# export SSH_AUTH_SOCK
# # see https://github.com/NixOS/nixpkgs/issues/14966#issuecomment-520083836
# mkdir -p "$HOME"/.local/share/keyrings
# 
# # keep screen on
# xset dpms 0 0 0
# xset s off
# xset -dpms
# xrandr --output DisplayPort-0 --mode 1920x1080 --rate 165 --set TearFree on
# exec i3

# see https://unix.stackexchange.com/a/295652/332452
source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh
# see https://wiki.archlinux.org/title/GNOME/Keyring#xinitrc
exec eval $(/usr/bin/gnome-keyring-daemon --start)
export SSH_AUTH_SOCK
# see https://github.com/NixOS/nixpkgs/issues/14966#issuecomment-520083836
mkdir -p "$HOME"/.local/share/keyrings

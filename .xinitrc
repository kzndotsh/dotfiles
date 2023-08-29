#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

userresources=$XDG_CONFIG_HOME/X11/xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps
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

# import_environment() {
  # systemctl --user import-environment DISPLAY XAUTHORITY
# }
# 
# update_activation_environment() {
  # if type dbus-update-activation-environment >/dev/null 2>&1; then
    # dbus-update-activation-environment --all
  # fi
# }
# 
# start_gnome_keyring_daemon() {
  # GNOME_KEYRING_DAEMON="/usr/bin/gnome-keyring-daemon"
  # if [ -f "$GNOME_KEYRING_DAEMON" ]; then
    # dbus-update-activation-environment --systemd DISPLAY
    # eval $("$GNOME_KEYRING_DAEMON" --start --components=gpg,pkcs11,secrets,ssh)
    # export GNOME_KEYRING_CONTROL GNOME_KEYRING_PID GPG_AGENT_INFO SSH_AUTH_SOCK &
  # fi
# }
# 
# start_polkit_gnome() {
  # /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
# }
# 
# main() {
  # import_environment
  # update_activation_environment
  # start_gnome_keyring_daemon
  # start_polkit_gnome
# }

# main

# # use systemd-environment-d-generator(8) to generate environment, and export those variables
export $(run-parts /usr/lib/systemd/user-environment-generators | sed '/:$/d; /^$/d' | xargs)

source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh

keychain ~/.ssh/id_ed25519
keychain ~/.ssh/id_rsa
[ -f ~/.keychain/$HOSTNAME-sh ] && . ~/.keychain/$HOSTNAME-sh 2>/dev/null
[ -f ~/.keychain/$HOSTNAME-sh-gpg ] && . ~/.keychain/$HOSTNAME-sh-gpg 2>/dev/null

export SSH_ASKPASS="/usr/lib/ssh/x11-ssh-askpass"

if [ -f /usr/bin/i3 ]; then
    exec i3
fi

if [ -f /usr/bin/feh ]; then
    feh --bg-scale ~/.wallpaper.jpg &
fi

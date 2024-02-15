#!/bin/zsh
#
# .zprofile - Zsh file loaded on login.
#

#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER="${BROWSER:-open}"
fi

#
# Tools
#

export BROWSER='firefox'
export EDITOR='micro'
export VISUAL='micro'
export READER='zathura'
export FILE='thunar'
export PAGER='less'
export LESS='-R '
export TERMINAL='alacritty'

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -Ug path PATH cdpath CDPATH fpath FPATH manpath MANPATH mailpath MAILPATH infopath INFOPATH

# Set the list of directories that zsh searches for commands.
path+=(
	/bin
	/usr/bin
	/usr/local/bin
	/usr/sbin
	/usr/local/sbin
	$HOME/.local/bin
	/var/lib/flatpak/exports/bin
	$HOME/.local/share/flatpak/exports/bin
	$HOME/.local/share/JetBrains/Toolbox/scripts
	$HOME/.config/emacs/bin
	$path
)

fpath+=(
	/usr/local/share/zsh/site-functions
	/usr/share/zsh/site-functions
	$HOME/.config/zsh/functions
	$fpath
)

infopath+=(
  /usr/local/share/info
  /usr/share/info
  $infopath
)

manpath+=(
  /usr/local/man
  /usr/local/share/man
  /usr/share/man
  $manpath
)

export PATH

#
# Misc
#

export TERM=xterm-256color
export CLICOLOR=1
export MICRO_TRUECOLOR=1
export COLORTERM=truecolor
export GPG_TTY="$(tty)"
export MAKEFLAGS="-j$(nproc)"


#
# Wayland
#
export MOZ_ENABLE_WAYLAND=1
export MOZ_DBUS_REMOTE=1
# export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME=gtk3
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export CLUTTER_BACKEND=wayland
export NO_AT_BRIDGE=1
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export GDK_BACKEND=“wayland,x11”
export GTK_THEME="TokyoNight"
export GTK_CSD=0

#
# XDG
#

export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GOPATH="$XDG_DATA_HOME"/go
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod
export PNPM_HOME="$XDG_DATA_HOME"/pnpm
export WORKON_HOME="$XDG_DATA_HOME/"virtualenvs
export PYTHON_EGG_CACHE="$XDG_CACHE_HOME"/python-eggs
export GRAB_HOME="$HOME"/repos
export MYPY_CACHE_DIR="$XDG_CACHE_HOME"/mypy
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME"/android
export WINEPREFIX="$XDG_DATA_HOME"/wineprefixes/default
export WGETRC="$XDG_CONFIG_HOME"/wgetrc
export LEDGER_FILE="$XDG_DATA_HOME"/hledger.journal
export WAKATIME_HOME="$XDG_CONFIG_HOME"/wakatime
export _Z_DATA="$XDG_DATA_HOME"/z
export CABAL_CONFIG="$XDG_CONFIG_HOME"/cabal/config
export CABAL_DIR="$XDG_DATA_HOME"/cabal
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export XCURSOR_PATH=/usr/share/icons:$XDG_DATA_HOME/icons
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc 
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc

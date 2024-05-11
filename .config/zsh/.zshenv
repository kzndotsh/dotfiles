#!/bin/zsh
#
# .zshenv - Zsh environment file, loaded always.
#

# NOTE: .zshenv needs to live at ~/.zshenv, not in $ZDOTDIR!

# Set ZDOTDIR if you want to re-home Zsh.
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export ZDOTDIR=${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}

# You can use .zprofile to set environment vars for non-login, non-interactive shells.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_STATE_HOME="$HOME"/.local/state
export XDG_CACHE_HOME="$HOME"/.cache

export XDG_SESSION_DESKTOP=sway
export XDG_CURRENT_DESKTOP=sway
export DE=sway
export WM=sway

export XDG_SESSION_TYPE=wayland
export MOZ_ENABLE_WAYLAND=1
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND="wayland,x11"
export GTK_CSD=0

export BROWSER=firefox
export TERMINAL=alacritty
export EDITOR=micro
export VISUAL=micro

export TERM=xterm-256color
export CLICOLOR=1
export MICRO_TRUECOLOR=1
export COLORTERM=truecolor
export GPG_TTY="$(tty)"
export MAKEFLAGS="-j$(nproc)"

export GTK_THEME="Tokyonight-Darker"
export BAT_THEME="tokyonight_night"
export GTK_CSD=0
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export _JAVA_AWT_WM_NONREPARENTING=1
export QT_QPA_PLATFORMTHEME=gtk3

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

export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export CARGO_HOME="$XDG_DATA_HOME"/cargo
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

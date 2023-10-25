# .zshenv

# This file is sourced on all invocations of the shell.
# It is the 1st file zsh reads; it's read for every shell,
# even if started with -f (setopt NO_RCS), all other
# initialization files are skipped.
#
# This file should contain commands to set the command
# search path, plus other important environment variables.
# This file should not contain commands that produce
# output or assume the shell is attached to a tty.
#
# Notice: .zshenv is the same, execpt that it's not read
# if zsh is started with -f
#
# Global Order: zshenv, zprofile, zshrc, zlogin

# Define DOTFILES directory
export DOTFILES="$HOME/dotfiles"

# ZSH
export ZDOTDIR="$DOTFILES/.config/zsh"
export HISTFILE="$XDG_CACHE_HOME"/zsh/zhistory

# OMZ
export ZSH="$DOTFILES/.config/zsh/omz"

# XDG
export XDG_SESSION_DESKTOP=i3
export XDG_CURRENT_DESKTOP=i3
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# X11
export SERXSESSION="$XDG_CACHE_HOME/X11/xsession"
export USERXSESSIONRC="$XDG_CACHE_HOME/X11/xsessionrc"
export ALTUSERXSESSION="$XDG_CACHE_HOME/X11/Xsession"
export ERRFILE="$XDG_CACHE_HOME/X11/xsession-errors"

# Ensure cache directory exists for zsh
mkdir -p "$XDG_CACHE_HOME/zsh"

# Ensure history directory and file exist for zsh
mkdir -p "$XDG_STATE_HOME/zsh"

export HISTSIZE=1000000
export SAVEHIST=1000000

# Secrets
source $HOME/.env

# Language
export LC_COLLATE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LC_MONETARY=en_US.UTF-8
export LC_NUMERIC=en_US.UTF-8
export LC_TIME=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LESSCHARSET=utf-8

# Applications
export BROWSER='firefoxdeveloperedition'
export TERMINAL='alacritty'
export FILE='thunar'
export READER='zathura'
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER='less'
export LESS='-R '

# DEV
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GOPATH="$XDG_DATA_HOME"/go
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod
export PNPM_HOME="$XDG_DATA_HOME"/pnpm
export PYTHON_EGG_CACHE="$XDG_CACHE_HOME"/python-eggs
export WORKON_HOME="$XDG_DATA_HOME/virtualenvs"
export GRAB_HOME="$HOME"/repos

# MISC
export TERM="xterm-256color"
export CLICOLOR=1
export MICRO_TRUECOLOR=1
export COLORTERM=truecolor
export MAKEFLAGS="-j$(nproc)"
export _JAVA_AWT_WM_NONREPARENTING=1
export GPG_TTY="$(tty)"

# MORE MISC
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME"/android
export WINEPREFIX="$XDG_DATA_HOME"/wineprefixes/default
export WGETRC="$XDG_CONFIG_HOME"/wgetrc
export LEDGER_FILE="$XDG_DATA_HOME"/hledger.journal
export WAKATIME_HOME="$XDG_CONFIG_HOME"/wakatime
export _Z_DATA="$XDG_DATA_HOME"/z
export CABAL_CONFIG="$XDG_CONFIG_HOME"/cabal/config
export CABAL_DIR="$XDG_DATA_HOME"/cabal
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java

typeset -Ug path PATH cdpath CDPATH fpath FPATH manpath MANPATH mailpath MAILPATH infopath INFOPATH

# Standards
path+=(
  /usr/local/sbin
  /usr/sbin
  /usr/local/bin
  /usr/bin
  "$HOME"/scripts
  "$HOME"/bin
  "$HOME"/.bin
  "$HOME"/.local/bin
  "$HOME"/.local/share/JetBrains/Toolbox/bin
  "$HOME"/.config/emacs/bin
)

# Flatpak Paths
path+=(
  /var/lib/flatpak/exports/bin
  "$HOME"/.local/share/flatpak/exports/bin
)

# Development Paths
path+=(
  "$HOME"/.cargo/bin
  "$HOME"/.local/share/cargo/bin
  "$HOME"/.console-ninja/.bin
  "$GOPATH"/bin
)

# Function Paths
fpath+=(
  "$DOTFILES"/.config/zsh/personal/completions
  "$DOTFILES"/.config/zsh/personal/functions
  # "$DOTFILES"/.config/zsh/functions.zsh
  /usr/local/share/zsh/site-functions
  /usr/share/zsh/site-functions
  $fpath
)

# CD Paths
cdpath+=(
  $cdpath
)

# Info Paths
infopath+=(
  /usr/local/share/info
  /usr/share/info
  $infopath
)

# Man Paths
manpath+=(
  /usr/local/man
  /usr/local/share/man
  /usr/share/man
  $manpath
)

export PATH

# GTK/QT stuff
export GDK_BACKEND=x11
export GDK_SCALE=1
# export GDK_CORE_DEVICE_EVENTS=1
unset GDK_CORE_DEVICE_EVENTS
# export GTK_USE_PORTAL=1
export GTK_CSD=0
export GTK_THEME=TokyoNight
export ICON_THEME=TokyoNight
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export QT_SCREEN_SCALE_FACTORS=1
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_ENABLE_HIGHDPI_SCALING=1
export QT_QPA_PLATFORMTHEME='gtk3'
export NO_AT_BRIDGE=1

# .zshenv

# Define DOTFILES directory
export DOTFILES="$HOME/dotfiles"

# ZSH
export ZDOTDIR="$DOTFILES/.config/zsh"

# XDG
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
touch "$XDG_CACHE_HOME/zsh/history"

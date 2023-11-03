export DOTFILES="$HOME/dotfiles"

export ZDOTDIR="$DOTFILES/.config/zsh"
export HISTFILE="$XDG_CACHE_HOME"/zsh/zhistory

# Session
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=sway
export XDG_CURRENT_DESKTOP=sway

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Ensure cache directory exists for zsh
mkdir -p "$XDG_CACHE_HOME/zsh"

# Ensure history directory and file exist for zsh
mkdir -p "$XDG_STATE_HOME/zsh"

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
)

# Flatpak Paths
path+=(
  /var/lib/flatpak/exports/bin
  "$HOME"/.local/share/flatpak/exports/bin
)

# Function Paths
fpath+=(
  "$DOTFILES"/.config/zsh/completions
  /usr/local/share/zsh/site-functions
  /usr/share/zsh/site-functions
  $fpath
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

export TERMINAL='kitty'
export TERM="xterm-256color"
export CLICOLOR=1
export MICRO_TRUECOLOR=1
export COLORTERM=truecolor

# Wayland stuff
export MOZ_ENABLE_WAYLAND=1 firefox
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export CLUTTER_BACKEND=wayland
export NO_AT_BRIDGE=1

# GTK
export GTK_THEME="Catppuccin-Mocha-Standard-Rosewater-Dark"

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

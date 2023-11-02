export DOTFILES="$HOME/dotfiles"

export ZDOTDIR="$DOTFILES/.config/zsh"
export HISTFILE="$XDG_CACHE_HOME"/zsh/zhistory

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

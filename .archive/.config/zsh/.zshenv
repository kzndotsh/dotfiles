export DOTFILES="$HOME/dotfiles"

export ZDOTDIR="$DOTFILES/.config/zsh"
export HISTFILE="$XDG_CACHE_HOME"/zsh/zhistory

# Session
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=sway
export XDG_CURRENT_DESKTOP=sway
export DE=sway
export WM=sway

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
	/bin
  /usr/local/sbin
  /usr/sbin
  /usr/local/bin
  /usr/bin
  "$HOME"/scripts
  "$HOME"/bin
  "$HOME"/.bin
  "$HOME"/.local/bin
  $path
)

# Flatpak Paths
path+=(
  /var/lib/flatpak/exports/bin
  "$HOME"/.local/share/flatpak/exports/bin
  $path
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

export BROWSER='firefox'
export EDITOR='micro'
export VISUAL='micro'
export READER='zathura'
export FILE='thunar'
export PAGER='less'
export LESS='-R '
export TERMINAL='kitty'

export TERM=xterm-kitty #xterm-256color
export CLICOLOR=1
export MICRO_TRUECOLOR=1
export COLORTERM=truecolor
export GPG_TTY="$(tty)"
export MAKEFLAGS="-j$(nproc)"

# Wayland stuff
export MOZ_ENABLE_WAYLAND=1
export MOZ_DBUS_REMOTE=1
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
# export QT_QPA_PLATFORMTHEME=qt6ct
export SDL_VIDEODRIVER=wayland
export _JAVA_AWT_WM_NONREPARENTING=1
export CLUTTER_BACKEND=wayland
export NO_AT_BRIDGE=1
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export GDK_BACKEND=wayland
export GTK_THEME="TokyoNight"
export GTK_CSD=0

# FZF
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"


export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GOPATH="$XDG_DATA_HOME"/go
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod
export PNPM_HOME="$XDG_DATA_HOME"/pnpm
export PYTHON_EGG_CACHE="$XDG_CACHE_HOME"/python-eggs
export WORKON_HOME="$XDG_DATA_HOME/"virtualenvs
export GRAB_HOME="$HOME"/repos
export MYPY_CACHE_DIR="$XDG_CACHE_HOME"/mypy
# export ASDF_DATA_DIR="${XDG_DATA_HOME}"/asdf
# export GNUPGHOME="$XDG_DATA_HOME"/gnupg
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
export XCURSOR_PATH=/usr/share/icons:$XDG_DATA_HOME/icons
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc 
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc




# environment.zsh

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
export TERMINAL='alacritty'
export FILE='thunar'
export READER='zathura'
export EDITOR="micro"
export VISUAL="micro"
export PAGER='less'
export LESS='-R '
export BROWSER='firefoxdeveloperedition'

# DEV
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export RBENV_ROOT="$XDG_DATA_HOME"/rbenv
export GOPATH="$XDG_DATA_HOME"/go
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export NVM_DIR="$XDG_DATA_HOME"/nvm
export PNPM_HOME="$XDG_DATA_HOME"/pnpm
export PYENV_ROOT="$XDG_DATA_HOME"/pyenv
export PYTHON_EGG_CACHE="$XDG_CACHE_HOME"/python-eggs
export WORKON_HOME="$XDG_DATA_HOME/virtualenvs"

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

typeset -Ug path PATH cdpath CDPATH fpath FPATH manpath MANPATH mailpath MAILPATH infopath INFOPATH

# Standards
path+=(
  /usr/local/sbin
  /usr/sbin
  /usr/local/bin
  /usr/bin
  "$HOME"/bin
  "$HOME"/.bin
  "$HOME"/.local/bin
  "$HOME"/.local/share/JetBrains/Toolbox/bin
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
  "$HOME"/.jenv/bin
  "$HOME"/.console-ninja/.bin
  "$GOPATH"/bin
  "$PYENV_ROOT"/bin
)

# Function Paths
fpath+=(
  "$DOTFILES"/.config/zsh/functions
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
export GDK_CORE_DEVICE_EVENTS=1
export GTK_USE_PORTAL=1
export GTK_CSD=0
export GTK_THEME=TokyoNight
export ICON_THEME=TokyoNight
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export QT_SCREEN_SCALE_FACTORS=1
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_ENABLE_HIGHDPI_SCALING=1
export QT_QPA_PLATFORMTHEME='qt5ct'
# GTK3 apps try to contact org.a11y.Bus. Disable that.
export NO_AT_BRIDGE=1

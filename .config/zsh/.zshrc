export XDG_DATA_HOME="$HOME"/.local/share
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_STATE_HOME="$HOME"/.local/state
export XDG_CACHE_HOME="$HOME"/.cache

# export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel

export ZDOTDIR="$HOME"/.config/zsh
export ZSH="$XDG_DATA_HOME"/oh-my-zsh

export HISTFILE="$XDG_STATE_HOME"/zsh/history
export HISTSIZE=1000000
export SAVEHIST=1000000
export HISTORY_IGNORE="(ls|bg|fg|pwd|exit|cd ..|cd -|pushd|popd|clear|..)"
setopt appendhistory     # Append history to the history file (no overwriting)
setopt sharehistory      # Share history across terminals
setopt incappendhistory  # Immediately append to the history file, not just

export SERXSESSION="$XDG_CACHE_HOME"/X11/xsession
export USERXSESSIONRC="$XDG_CACHE_HOME"/X11/xsessionrc
export ALTUSERXSESSION="$XDG_CACHE_HOME"/X11/Xsession
export ERRFILE="$XDG_CACHE_HOME"/X11/xsession-errors

export GOPATH="$XDG_DATA_HOME"/go
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod

# export GTK_THEME=TokyoNight
# export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
# export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export LEDGER_FILE="$XDG_DATA_HOME"/hledger.journal

export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export NVM_DIR="$XDG_DATA_HOME"/nvm

export PYENV_ROOT="$XDG_DATA_HOME"/pyenv
export PYTHON_EGG_CACHE="$XDG_CACHE_HOME"/python-eggs

export RUSTUP_HOME="$XDG_DATA_HOME"/rustup

export WAKATIME_HOME="$XDG_CONFIG_HOME"/wakatime

export WGETRC="$XDG_CONFIG_HOME"/wgetrc

export WINEPREFIX="$XDG_DATA_HOME"/wineprefixes/default

export _Z_DATA="$XDG_DATA_HOME"/z

export ANDROID_SDK_HOME="$XDG_CONFIG_HOME"/android

export CARGO_HOME="$XDG_DATA_HOME"/cargo


# ZSH_THEME="agnoster"

# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time
# zstyle ':omz:update' frequency 13
# DISABLE_MAGIC_FUNCTIONS="true"
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
# ENABLE_CORRECTION="true"
# COMPLETION_WAITING_DOTS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
# HIST_STAMPS="mm/dd/yyyy"
# ZSH_CUSTOM=/path/to/new-custom-folder

plugins=(git)

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

########## TOOLS
export BROWSER='firefox'
export TERMINAL='alacritty'
export EDITOR='micro'
# export MANPAGER='bat'
# export MANROFFOPT="-c"
export PAGER='bat'
export READER='zathura'
export FILE='pcmanfm'



########## COLORS
eval $(dircolors "$XDG_CONFIG_HOME"/dircolors)
# export TERM=screen-256color   
# export TERM=rxvt-unicode-256color
export TERM=xterm-256color
export MICRO_TRUECOLOR=1
export CLICOLOR=1


# export LESS_TERMCAP_mb=$(printf '\e[01;31m') # enter blinking mode - red
# export LESS_TERMCAP_md=$(printf '\e[01;35m') # enter double-bright mode - bold, magenta
# export LESS_TERMCAP_me=$(printf '\e[0m')     # turn off all appearance modes (mb, md, so, us)
# export LESS_TERMCAP_se=$(printf '\e[0m')     # leave standout mode
# export LESS_TERMCAP_so=$(printf '\e[01;33m') # enter standout mode - yellow
# export LESS_TERMCAP_ue=$(printf '\e[0m')     # leave underline mode
# export LESS_TERMCAP_us=$(printf '\e[04;36m') # enter underline mode - cyan

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias tree="tree -C"
alias diff="diff --color"


# export GDK_BACKEND=x11
export GTK_USE_PORTAL=1
export QT_SCREEN_SCALE_FACTORS=1.75
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export GDK_CORE_DEVICE_EVENTS=1
# export GTK_CSD=0 # titlebars

########## COMPLETIONS
autoload -Uz compinit
zstyle ':completion:*' cache-path $XDG_CACHE_HOME/zsh/zcompcache
zmodload zsh/complist
[ ! -d "$XDG_CACHE_HOME/zsh" ] && mkdir "$XDG_CACHE_HOME/zsh"
compinit -d $XDG_CACHE_HOME/zsh/zcompdump

[[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh

source /usr/share/nvm/nvm.sh
source /usr/share/nvm/bash_completion
source /usr/share/nvm/install-nvm-exec

# if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    # ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
# fi
# if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    # source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
# fi

eval $(keychain --eval --quiet id_ed25519 id_rsa)

# Packages I Installed
alias pii="comm -23 <(pacman -Qqett | sort) <(pacman -Qqg base -g base-devel | sort | uniq)"

# Some tmux aliases
alias tl='tmux list-sessions'
alias tk="tmux kill-session -t tmux list-sessions | fzf | cut -d ':' -f1"
alias td='tmux detach'

# Some git aliases
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gs="git status"
alias gd="git diff"

# [J]ust [P]ush
# Sometimes I just need to push the code and dont care about the commit message
alias jp="git add . && git commit -m \"$(date)\" && git push"

# Use 'exa' instead of 'ls'
# alias ls="exa"
# alias ll='exa -alF'
# alias la='exa -a'
# alias l='exa -CF'




# --interactive     prompt before overwrite
# --verbose         explain what is being done
alias cp="cp --interactive --verbose"
alias mv="mv --interactive --verbose"
alias rm="rm --verbose"

########### PATHS
# man pages
export MANPATH="/usr/local/man:$MANPATH"
# local binaries
path+=('~/bin')
path+=('~/.bin')
path+=('~/.local/bin')
# flatpak
path+=('/var/lib/flatpak/exports/bin')
path+=('~/.local/share/flatpak/exports/bin')
# cargo
path+=('$HOME/.cargo/bin')
path+=('$HOME/.local/share/cargo/bin')
# java
path+=('$HOME/.jenv/bin')
export PATH

eval "$(jenv init -)"

eval "$(starship init zsh)"

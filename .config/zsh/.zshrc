########## EXPORTS

###### XDG EXPORTS
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_STATE_HOME="$HOME"/.local/state
export XDG_CACHE_HOME="$HOME"/.cache

##### X11 EXPORTS
export SERXSESSION="$XDG_CACHE_HOME"/X11/xsession
export USERXSESSIONRC="$XDG_CACHE_HOME"/X11/xsessionrc
export ALTUSERXSESSION="$XDG_CACHE_HOME"/X11/Xsession
export ERRFILE="$XDG_CACHE_HOME"/X11/xsession-errors

##### ZSH EXPORTS
export ZDOTDIR="$HOME"/.config/zsh
export ZSH="$XDG_DATA_HOME"/oh-my-zsh
# ZSH_THEME="agnoster"

##### HISTORY EXPORTS
export HISTFILE="$XDG_STATE_HOME"/zsh/history
export HISTSIZE=1000000
export SAVEHIST=1000000
export HISTORY_IGNORE="(ls|bg|fg|pwd|exit|cd ..|cd -|pushd|popd|clear|..)"
setopt appendhistory     # Append history to the history file (no overwriting)
setopt sharehistory      # Share history across terminals
setopt incappendhistory  # Immediately append to the history file, not just

##### GTK EXPORTS
# export GTK_THEME=TokyoNight
# export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
# export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
# export GDK_BACKEND=x11
# export GTK_CSD=0 # titlebars
export GTK_USE_PORTAL=1
export QT_SCREEN_SCALE_FACTORS=1.75
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export GDK_CORE_DEVICE_EVENTS=1
export QT_QPA_PLATFORMTHEME='gtk3'

###### DEVELOPMENT EXPORTS

## JAVASCRIPT
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export NVM_DIR="$XDG_DATA_HOME"/nvm

## PYTHON
export PYENV_ROOT="$XDG_DATA_HOME"/pyenv
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export WORKON_HOME="$XDG_DATA_HOME/virtualenvs"
source /usr/bin/virtualenvwrapper.sh 
export PYTHON_EGG_CACHE="$XDG_CACHE_HOME"/python-eggs

## RUBY
export RBENV_ROOT="$XDG_DATA_HOME"/rbenv

## RUST
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export CARGO_HOME="$XDG_DATA_HOME"/cargo

## GO
export GOPATH="$XDG_DATA_HOME"/go
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod

##### MISC EXPORTS
# export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME"/android
export WINEPREFIX="$XDG_DATA_HOME"/wineprefixes/default
export WGETRC="$XDG_CONFIG_HOME"/wgetrc
export LEDGER_FILE="$XDG_DATA_HOME"/hledger.journal
export WAKATIME_HOME="$XDG_CONFIG_HOME"/wakatime
export _Z_DATA="$XDG_DATA_HOME"/z

# Make flags
export MAKEFLAGS="-j$(nproc)"

########## LOCALES
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

########## TOOLS
export BROWSER='firefox'
export TERMINAL='alacritty'
export EDITOR='micro'
# export MANPAGER='bat'
# export MANROFFOPT="-c"
export PAGER='less'
export LESSOPEN="| /usr/bin/source-highlight-esc.sh %s"
export LESS='-R '
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
# Fix java apps for non-re-parenting window managers (like sway)
# export _JAVA_AWT_WM_NONREPARENTING=1

# Catppuccin Mocha Theme (for zsh-syntax-highlighting)
# Paste this files contents inside your ~/.zshrc before you activate zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main cursor)
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=#51566a'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#9ece6a'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#9ece6a'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#9ece6a'
ZSH_HIGHLIGHT_STYLES[function]='fg=#9ece6a'
ZSH_HIGHLIGHT_STYLES[command]='fg=#9ece6a'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#9ece6a,italic'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#ff9e64,italic'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#ff9e64'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#ff9e64'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#bb9af7'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#9ece6a'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#9ece6a'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#9ece6a'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#f7768e'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#c0caf5'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=#c0caf5'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#c0caf5'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#f7768e'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#f7768e'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#f7768e'
ZSH_HIGHLIGHT_STYLES[command-substitution-quoted]='fg=#e0af68'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-quoted]='fg=#e0af68'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#e0af68'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument-unclosed]='fg=#e64553'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#e0af68'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument-unclosed]='fg=#e64553'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#e0af68'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#c0caf5'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument-unclosed]='fg=#e64553'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#c0caf5'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#c0caf5'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#c0caf5'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#c0caf5'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#e64553'
ZSH_HIGHLIGHT_STYLES[path]='fg=#c0caf5,underline'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#f7768e,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#c0caf5,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#f7768e,underline'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#c0caf5'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#bb9af7'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-unclosed]='fg=#e64553'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#c0caf5'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#c0caf5'
ZSH_HIGHLIGHT_STYLES[default]='fg=#c0caf5'
ZSH_HIGHLIGHT_STYLES[cursor]='fg=#c0caf5'

########## OH MY ZSH

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

##### OMZ PLUGINS
plugins=(git gh extract git-extras virtualenv virtualenvwrapper z tmux transfer npm nvm safe-paste sudo last-working-dir magic-enter fd fzf archlinux command-not-found copybuffer copyfile copypath dirhistory direnv)
##### OMZ SOURCE
source $ZSH/oh-my-zsh.sh

########## COMPLETIONS
autoload -Uz compinit
zstyle ':completion:*' cache-path $XDG_CACHE_HOME/zsh/zcompcache
zmodload zsh/complist
[ ! -d "$XDG_CACHE_HOME/zsh" ] && mkdir "$XDG_CACHE_HOME/zsh"
compinit -d $XDG_CACHE_HOME/zsh/zcompdump

[[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh

# nvm
source /usr/share/nvm/nvm.sh
source /usr/share/nvm/bash_completion
source /usr/share/nvm/install-nvm-exec

# fzf
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# git-extras
source /usr/share/doc/git-extras/git-extras-completion.zsh

########## SSH/GPG STUFF

# if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    # ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
# fi
# if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    # source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
# fi

# gpg (for Github)
# export GPG_TTY="$(tty)"

eval $(keychain --eval --quiet id_ed25519 id_rsa)

########## ALIASES 
alias edit-i3="micro ~/dotfiles/.config/i3/config"
alias edit-polybar="micro ~/dotfiles/.config/polybar/config.ini"
alias edit-zsh="micro ~/dotfiles/.config/zsh/.zshrc"
alias cat='bat'
alias bat='bat'
alias nano='micro'
alias emptydirs='find . -type d -empty -delete'
alias dotfiles='~/dotfiles'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias tree="tree -C"
alias diff="diff --color"
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
# Prints your command history
alias h="history"
# Use grep to search your command history
alias hs="history | grep"
# Use grep to do a case-insensitive search of your command history
alias hsi="history | grep -i" 	
# Display PATH with each entry per line
alias path="print -l $path"
# [J]ust [P]ush
# Sometimes I just need to push the code and dont care about the commit message
alias jp="git add . && git commit -m \"$(date)\" && git push"
alias cp="cp --interactive --verbose"
alias mv="mv --interactive --verbose"
alias rm="rm --verbose"
alias mkdir="mkdir -pv"
# Exa wrapper
if command -v exa >/dev/null; then
    alias ls="~/scripts/exa-wrapper.sh"
else
    alias ls="command ls $LS_OPTIONS"
fi

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

# zsh-syntax-highlighting and autosuggestions
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

########## STARSHIP PROMPT
eval "$(starship init zsh)"


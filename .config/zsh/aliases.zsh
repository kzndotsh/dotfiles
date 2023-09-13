# aliases.zsh

# Quick access to dotfile editing
alias edit-i3='"$EDITOR" "$DOTFILES"/.config/i3/config'
alias edit-polybar='"$EDITOR" "$DOTFILES"/.config/polybar/config.ini'
alias edit-zsh='"$EDITOR" "$DOTFILES"/.config/zsh/.zshrc'

# Replacing tools with better ones
alias nano='micro'
alias cat='bat'
alias man='batman'
alias grep='batgrep'

# Some useful one liners
alias emptydirs='find . -type d -empty -delete'
alias flattendir='find . -mindepth 2 -type f -print -exec mv {} . \;'
alias count='ls | wc -l'
alias path='print -l "$PATH"'
alias pii="comm -23 <(pacman -Qqett | sort) <(pacman -Qqg base -g base-devel | sort | uniq)"

# Color output for some commands
# alias grep='grep --color=auto'
# alias fgrep='fgrep --color=auto'
# alias egrep='egrep --color=auto'
alias tree="tree -C"
alias diff="diff --color"
alias http='http -s dracula --verbose'

# Basic commands with flag tweaks
alias cp="cp --interactive --verbose"
alias mv="mv --interactive --verbose"
alias rm="rm --verbose"
alias mkdir="mkdir -pv"

# List directory contents

alias l='ls -lFh'   #size,show type,human readable
alias la='ls -lAFh' #long list,show almost all,show type,human readable
alias lr='ls -tRFh' #sorted by date,recursive,show type,human readable
alias lt='ls -ltFh' #long list,sorted by date,show type,human readable
alias ll='ls -l'    #long list
alias ldot='ls -ld .*'
alias lS='ls -1FSsh'
alias lart='ls -1Fcart'
alias lrt='ls -1Fcrt'
alias lsr='ls -lARFh' #Recursive list of files and directories
alias lsn='ls -1'     #A column contains name of files and directories

# Exa wrapper
if command -v exa >/dev/null; then
    alias ls='"$DOTFILES"/scripts/exa-wrapper.sh'
else
    alias ls="command ls $LS_OPTIONS"
fi

# Tmux aliases
alias tl='tmux list-sessions'
alias tk="tmux kill-session -t tmux list-sessions | fzf | cut -d ':' -f1"
alias td='tmux detach'

# Git aliases
alias jp="git add . && git commit -m \"$(date)\" && git push"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gs="git status"
alias gd="git diff"

# Lazy
alias md="mkdir"
alias t="touch"
alias x="exit"
alias c="clear"
# alias o="xdg-open"
alias x+="chmod +x"
alias get="curl -O -L"

# WIP:
alias shutdown='sudo shutdown now'
alias restart='sudo reboot'
alias suspend='sudo pm-suspend'
alias audio-reset="puleaudio -k && sudo alsa force-reload && pulseaudio --start"

# Command line head / tail shortcuts
# alias -g H='| head'
# alias -g T='| tail'
# alias -g G='| grep'
# alias -g L="| less"
# alias -g M="| most"
# alias -g LL="2>&1 | less"
# alias -g CA="2>&1 | cat -A"
# alias -g NE="2> /dev/null"
# alias -g NUL="> /dev/null 2>&1"



# commonly used dirs

# alias dev="cd ~/dev"
# alias work="cd ~/dev/work"
# alias desk="cd ~/desktop"
# alias docs="cd ~/documents"
# alias dl="cd ~/downloads"
# alias home="cd ~"
# alias dots="cd ~/dotfiles"
# alias dotfiles="cd ~/dotfiles"


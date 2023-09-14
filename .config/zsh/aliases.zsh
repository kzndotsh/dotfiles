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
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -v"
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

# Exa (ls replacement) wrapper
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

# alias ggpur='ggu'
# alias g='git'
# alias ga='git add'
# alias gaa='git add --all'
# alias gapa='git add --patch'
# alias gau='git add --update'
# alias gav='git add --verbose'
# alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"'
# alias gam='git am'
# alias gama='git am --abort'
# alias gamc='git am --continue'
# alias gamscp='git am --show-current-patch'
# alias gams='git am --skip'
# alias gap='git apply'
# alias gapt='git apply --3way'
# alias gbs='git bisect'
# alias gbsb='git bisect bad'
# alias gbsg='git bisect good'
# alias gbsn='git bisect new'
# alias gbso='git bisect old'
# alias gbsr='git bisect reset'
# alias gbss='git bisect start'
# alias gbl='git blame -w'
# alias gb='git branch'
# alias gba='git branch --all'
# alias gbd='git branch --delete'
# alias gbD='git branch --delete --force'
# alias gbda='git branch --no-color --merged | command grep -vE "^([+*]|\s*($(git_main_branch)|$(git_develop_branch))\s*$)" | command xargs git branch --delete 2>/dev/null'
# alias gbgd='LANG=C git branch --no-color -vv | grep ": gone\]" | awk '"'"'{print $1}'"'"' | xargs git branch -d'
# alias gbgD='LANG=C git branch --no-color -vv | grep ": gone\]" | awk '"'"'{print $1}'"'"' | xargs git branch -D'
# alias gbnm='git branch --no-merged'
# alias gbr='git branch --remote'
# alias ggsup='git branch --set-upstream-to=origin/$(git_current_branch)'
# alias gbg='LANG=C git branch -vv | grep ": gone\]"'
# alias gco='git checkout'
# alias gcor='git checkout --recurse-submodules'
# alias gcb='git checkout -b'
# alias gcd='git checkout $(git_develop_branch)'
# alias gcm='git checkout $(git_main_branch)'
# alias gcp='git cherry-pick'
# alias gcpa='git cherry-pick --abort'
# alias gcpc='git cherry-pick --continue'
# alias gclean='git clean --interactive -d'
# alias gcl='git clone --recurse-submodules'
# alias gcam='git commit --all --message'
# alias gcas='git commit --all --signoff'
# alias gcasm='git commit --all --signoff --message'
# alias gcs='git commit --gpg-sign'
# alias gcss='git commit --gpg-sign --signoff'
# alias gcssm='git commit --gpg-sign --signoff --message'
# alias gcmsg='git commit --message'
# alias gcsm='git commit --signoff --message'
# alias gc='git commit --verbose'
# alias gca='git commit --verbose --all'
# alias gca!='git commit --verbose --all --amend'
# alias gcan!='git commit --verbose --all --no-edit --amend'
# alias gcans!='git commit --verbose --all --signoff --no-edit --amend'
# alias gc!='git commit --verbose --amend'
# alias gcn!='git commit --verbose --no-edit --amend'
# alias gcf='git config --list'
# alias gdct='git describe --tags $(git rev-list --tags --max-count=1)'
# alias gd='git diff'
# alias gdca='git diff --cached'
# alias gdcw='git diff --cached --word-diff'
# alias gds='git diff --staged'
# alias gdw='git diff --word-diff'
# alias gfo='git fetch origin'
# alias gg='git gui citool'
# alias gga='git gui citool --amend'
# alias ghh='git help'
# alias glgg='git log --graph'
# alias glgga='git log --graph --decorate --all'
# alias glgm='git log --graph --max-count=10'
# alias glods='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short'
# alias glod='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset"'
# alias glola='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
# alias glols='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat'
# alias glol='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
# alias glo='git log --oneline --decorate'
# alias glog='git log --oneline --decorate --graph'
# alias gloga='git log --oneline --decorate --graph --all'
# alias gdt='git diff-tree --no-commit-id --name-only -r'
# alias gf='git fetch'
# alias gupom='git pull --rebase origin $(git_main_branch)'
# alias gupomi='git pull --rebase=interactive origin $(git_main_branch)'
# alias ggpull='git pull origin "$(git_current_branch)"'
# alias gluc='git pull upstream $(git_current_branch)'
# alias glum='git pull upstream $(git_main_branch)'
# alias gp='git push'
# alias gpd='git push --dry-run'
# alias gpu='git push upstream'
# alias grb='git rebase'
# alias grba='git rebase --abort'
# alias grbc='git rebase --continue'
# alias grbi='git rebase --interactive'
# alias grbo='git rebase --onto'
# alias grbs='git rebase --skip'
# alias grbd='git rebase $(git_develop_branch)'
# alias grbm='git rebase $(git_main_branch)'
# alias grbom='git rebase origin/$(git_main_branch)'
# alias gr='git remote'
# alias grv='git remote --verbose'
# alias gra='git remote add'
# alias grrm='git remote remove'
# alias grmv='git remote rename'
# alias grset='git remote set-url'
# alias grup='git remote update'
# alias grh='git reset'
# alias gru='git reset --'
# alias grhh='git reset --hard'
# alias gpristine='git reset --hard && git clean --force -dfx'
# alias groh='git reset origin/$(git_current_branch) --hard'
# alias grs='git restore'
# alias grss='git restore --source'
# alias grst='git restore --staged'
# alias gunwip='git rev-list --max-count=1 --format="%s" HEAD | grep -q "\--wip--" && git reset HEAD~1'
# alias grev='git revert'
# alias grm='git rm'
# alias grmc='git rm --cached'
# alias gcount='git shortlog --summary --numbered'
# alias gsh='git show'
# alias gsps='git show --pretty=short --show-signature'
# alias gstall='git stash --all'
# alias gstaa='git stash apply'
# alias gstc='git stash clear'
# alias gstd='git stash drop'
# alias gstl='git stash list'
# alias gstp='git stash pop'

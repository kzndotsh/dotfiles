#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


# profile
[[ -f "$HOME/.bash_profile" ]] \
    && source "$HOME/.bash_profile"

# eval dircolors
[[ -f "$HOME/.dir_colors" ]] \
    && eval "$(dircolors "$HOME/.dir_colors")"

alias ls='ls --color=auto'
alias grep='grep --color=auto'

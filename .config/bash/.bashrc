#!/usr/bin/env bash

# ${HOME}/.bashrc: executed by bash(1) for non-login shells.
# If not running interactively, don't do anything
[ -z "$PS1" ] && return



# [[ $- != *i* ]] && return
# PS1='[\u@\h \W]\$ '

# PATH=~/.console-ninja/.bin:$PATH

# [[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    # . /usr/share/bash-completion/bash_completion

# Auto "cd" when entering just a path
shopt -s autocd

# Line wrap on window resize
shopt -s checkwinsize






# ALIASES

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'


alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# makes color constants available
autoload -U colors
colors

# # Default coloring for GNU-based ls
# if [[ -z "$LS_COLORS" ]]; then
#   # Define LS_COLORS via dircolors if available. Otherwise, set a default
#   # equivalent to LSCOLORS (generated via https://geoff.greer.fm/lscolors)
#   if (( $+commands[dircolors] )); then
#     [[ -f "$HOME/.dircolors" ]] \
#       && source <(dircolors -b "$HOME/.dircolors") \
#       || source <(dircolors -b)
#   else
#     export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
#   fi
# fi

eval $(dircolors "$DOTFILES"/.config/dircolors)

if command -v dircolors &>/dev/null && [[ -e "$DOTFILES/.config/dircolors" ]]; then
  eval "$(dircolors -b "$DOTFILES/.config/dircolors")"
fi

source "$ZDOTDIR"/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# zstyle ':completion:*:*:*:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*' list-colors "$LS_COLORS"

export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

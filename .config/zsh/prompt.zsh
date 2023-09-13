# prompt.zsh

path+="$ZDOTDIR"/prompts

# autoload -Uz promptinit; promptinit

# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Starship prompt
if [[ $(command -v starship) ]]; then
  eval "$(starship init zsh)"
else
  echo "No prompt not installed"
fi

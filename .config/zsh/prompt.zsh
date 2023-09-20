## prompt.zsh

## Custom prompts
path+="$ZDOTDIR"/prompts

## P10k prompt
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

## Pure prompt
fpath+=($ZDOTDIR/prompts/pure)
autoload -Uz promptinit; promptinit
prompt pure
zstyle :prompt:pure:git:stash show yes

## Starship prompt
# if [[ $(command -v starship) ]]; then
#   eval "$(starship init zsh)"
# else
#   echo "No prompt not installed"
# fi

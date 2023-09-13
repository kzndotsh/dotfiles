# init.zsh

# Should be called before compinit
zmodload zsh/complist

# Load and initialize the completion system ignoring insecure directories.
autoload -Uz compinit && compinit -i -d "$XDG_CACHE_HOME"/zsh/zcompdump

# Source files (the order matters).
# source "${0:h}/helper.zsh"
source "${0:h}"/environment.zsh
# source "${0:h}/terminal.zsh
# source "${0:h}/keyboard.zsh
source "${0:h}"/completions.zsh
source "${0:h}"/history.zsh
source "${0:h}"/directories.zsh
source "${0:h}"/aliases.zsh
# source "${0:h}/utility.zsh
source "${0:h}"/functions.zsh
source "${0:h}"/misc.zsh
source "${0:h}"/prompt.zsh
source "${0:h}"/colors.zsh

# Autoload Zsh functions
autoload -Uz is-at-least
autoload -Uz age
autoload -Uz zargs
autoload -Uz zcalc
autoload -Uz zmv
autoload -Uz allopt
autoload -Uz run-help
autoload -Uz zsh-mime-setup && zsh-mime-setup
autoload -Uz url-quote-magic && zle -N self-insert url-quote-magic

# Development stuff
source /usr/bin/virtualenvwrapper.sh
eval "$(pyenv init -)"
eval "$(rbenv init -)"
eval "$(jenv init -)"

# Compile the completion dump, to increase startup speed.
dump_file="$XDG_CACHE_HOME"/zsh/zcompdump
if [[ "$dump_file" -nt "${dump_file}.zwc" || ! -f "${dump_file}.zwc" ]]; then
  zcompile "$dump_file"
fi
unset dump_file

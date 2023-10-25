# Path to your oh-my-zsh installation.
export ZSH="$ZDOTDIR/omz"

ZSH_THEME=""

plugins=(
  git
  git-extras
  safe-paste
  copyfile
  extract
)

source $ZSH/oh-my-zsh.sh

# Starship prompt
if [[ $(command -v starship) ]]; then
  eval "$(starship init zsh)"
else
  echo "No prompt not installed"
fi

# COLORS
if command -v dircolors &>/dev/null && [[ -e "$DOTFILES/.config/dircolors" ]]; then
  eval "$(dircolors -b "$DOTFILES/.config/dircolors")"
fi

# CUSTOM PLUGINS
source "$ZDOTDIR"/personal/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source "$ZDOTDIR"/personal/plugins/zsh-alias-tips/alias-tips.plugin.zsh
source "$ZDOTDIR"/personal/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source "$ZDOTDIR"/personal/plugins/zsh-autopair/autopair.zsh
autopair-init
fpath+="$ZDOTDIR"/personal/plugins/zsh-completions/src

# source /usr/share/nvm/nvm.sh
# source /usr/share/nvm/bash_completion
# source /usr/share/nvm/install-nvm-exec
# source /usr/share/nvm/init-nvm.sh
# source /usr/share/fzf/key-bindings.zsh
# source /usr/share/fzf/completion.zsh
# source /usr/share/doc/git-extras/git-extras-completion.zsh
# source /usr/share/doc/pkgfile/command-not-found.zsh

# Z DIRECTORY JUMPING
# [[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh

# source "$ZDOTDIR"/personal/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source "$ZDOTDIR"/personal/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# ASDF version manager
. /opt/asdf-vm/asdf.sh
source "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"

# source "$HOME/.rye/env"


# Aliases
source "$ZDOTDIR"/personal/aliases.zsh

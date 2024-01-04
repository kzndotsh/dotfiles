# plugins.zsh

# # clone your external plugins if needed
# external_plugins=(
#   zsh-users/zsh-autosuggestions
#   marlonrichert/zsh-hist
#   zsh-users/zsh-syntax-highlighting
# )
# for repo in $external_plugins; do
#   if [[ ! -d $ZSH_CUSTOM/${repo:t} ]]; then
#     git clone https://github.com/${repo} $ZSH_CUSTOM/plugins/${repo:t}
#   fi
# done

# # set your normal oh-my-zsh plugins
# plugins=(
#   git
#   magic-enter
# )

# # now add your external plugins to your OMZ plugins list
# plugins+=(${external_plugins:t})

# # then source oh-my-zsh
# source $ZSH/oh-my-zsh.sh

##### OMZ PLUGINS
# plugins=(git gh extract git-extras virtualenv virtualenvwrapper z tmux transfer npm nvm safe-paste sudo last-working-dir magic-enter fd fzf archlinux command-not-found copybuffer copyfile copypath dirhistory direnv)
# source $ZSH/oh-my-zsh.sh


source "$ZDOTDIR"/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source "$ZDOTDIR"/plugins/zsh-alias-tips/alias-tips.plugin.zsh
source "$ZDOTDIR"/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh   


# TBD:
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git-commit/git-commit.plugin.zsh

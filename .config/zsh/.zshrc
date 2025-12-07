#!/bin/zsh#
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/.local/share/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/zshrc.pre.zsh"
# .zshrc - Zsh file loaded on interactive shell sessions.
#

# Zsh options.
# setopt extended_glob


# Autoload functions you might want to use with antidote.
ZFUNCDIR=${ZFUNCDIR:-$ZDOTDIR/functions}

fpath=($ZFUNCDIR $fpath)

# setopt NULL_GLOB

if (( ${#fpath[1]/*(.:t)} )); then
  autoload -Uz $fpath[1]/*(.:t)
fi

# Source zstyles you might use with antidote.
[[ -e ${ZDOTDIR:-~}/.zstyles ]] && source ${ZDOTDIR:-~}/.zstyles

# Clone antidote if necessary.
[[ -d ${ZDOTDIR:-~}/.antidote ]] ||
  git clone https://github.com/mattmc3/antidote ${ZDOTDIR:-~}/.antidote

# Create an amazing Zsh config using antidote plugins.
source ${ZDOTDIR:-~}/.antidote/antidote.zsh

antidote load

export LS_COLORS="$(vivid generate tokyonight-night)"

alias hh=hstr                    # hh to be alias for hstr
setopt histignorespace           # skip cmds w/ leading space from history
export HSTR_CONFIG=hicolor       # get more colors

hstr_no_tiocsti() {
    zle -I
    { HSTR_OUT="$( { </dev/tty hstr ${BUFFER}; } 2>&1 1>&3 3>&- )"; } 3>&1;
    BUFFER="${HSTR_OUT}"
    CURSOR=${#BUFFER}
    zle redisplay
}

zle -N hstr_no_tiocsti

bindkey '\C-r' hstr_no_tiocsti

export HSTR_TIOCSTI=n

source ${ZDOTDIR:-~}/.functions
source <(tdl completion zsh)

bindkey '^[[1;5C' emacs-forward-word
bindkey '^[[1;5D' emacs-backward-word
bindkey '^[[1;5A' up-line-or-history    # Ctrl + UP
bindkey '^[[1;5B' down-line-or-history  # Ctrl + DOWN

eval "$(mise activate zsh)"

export PATH=$PATH:/home/kaizen/.spicetify

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/.local/share/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/zshrc.post.zsh"

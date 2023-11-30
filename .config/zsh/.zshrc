# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ${ZDOTDIR:-$HOME}/.antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

eval "$(/home/kaizen/.local/share/rtx/bin/rtx activate zsh)"

source ~/.config/dircolors/LS_COLORS/lscolors.sh

source ~/.config/.aliases

# if ! pgrep -u "$USER" ssh-agent > /dev/null; then
#     ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
# fi
# if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
#     source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
# fi

# Ensure the XDG_RUNTIME_DIR is set
XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-kaizen}"
mkdir -p "$XDG_RUNTIME_DIR"

# Create or ensure the keychain directory exists
KEYCHAIN_DIR="$XDG_RUNTIME_DIR/keychain"
mkdir -p "$KEYCHAIN_DIR"

# Add SSH keys to keychain
keychain --dir "$KEYCHAIN_DIR" ~/.ssh/id_ed25519 || {
    echo "Error adding id_ed25519 to keychain" >&2
    exit 1
}

keychain --dir "$KEYCHAIN_DIR" ~/.ssh/id_rsa || {
    echo "Error adding id_rsa to keychain" >&2
    exit 1
}

# Source keychain files if they exist
if [ -f "$KEYCHAIN_DIR/arch-sh" ]; then
    source "$KEYCHAIN_DIR/arch-sh" 2>/dev/null
fi

if [ -f "$KEYCHAIN_DIR/arch-sh-gpg" ]; then
    source "$KEYCHAIN_DIR/arch-sh-gpg" 2>/dev/null
fi

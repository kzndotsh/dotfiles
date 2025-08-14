# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/.local/share/amazon-q/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/.local/share/amazon-q/shell/zprofile.pre.zsh"

export ZPROFILE_LOADED=1

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/.local/share/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/.local/share/amazon-q/shell/zprofile.post.zsh"

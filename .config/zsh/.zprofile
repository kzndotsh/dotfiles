# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/.local/share/kiro-cli/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/zprofile.pre.zsh"
export ZPROFILE_LOADED=1

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/.local/share/kiro-cli/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/zprofile.post.zsh"

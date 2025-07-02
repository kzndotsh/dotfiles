source "$ZDOTDIR/.aliases"
fpath+=( "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-mattmc3-SLASH-ez-compinit" )
source "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-mattmc3-SLASH-ez-compinit/ez-compinit.plugin.zsh"
fpath+=( "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-completions/src" )
fpath+=( "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-belak-SLASH-zsh-utils/completion" )
source "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-belak-SLASH-zsh-utils/completion/completion.plugin.zsh"
fpath+=( "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-getantidote-SLASH-use-omz" )
source "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-getantidote-SLASH-use-omz/antidote-use-omz.plugin.zsh"
source "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-getantidote-SLASH-use-omz/use-omz.plugin.zsh"
fpath+=( "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh/plugins/extract" )
source "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-ohmyzsh-SLASH-ohmyzsh/plugins/extract/extract.plugin.zsh"
fpath+=( "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-belak-SLASH-zsh-utils/history" )
source "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-belak-SLASH-zsh-utils/history/history.plugin.zsh"
fpath+=( "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-sindresorhus-SLASH-pure" )
source "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-sindresorhus-SLASH-pure/pure.plugin.zsh"
fpath+=( "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-mattmc3-SLASH-zfunctions" )
source "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-mattmc3-SLASH-zfunctions/zfunctions.plugin.zsh"
fpath+=( "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions" )
source "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
fpath+=( "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-history-substring-search" )
source "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zsh-users-SLASH-zsh-history-substring-search/zsh-history-substring-search.plugin.zsh"
if ! (( $+functions[zsh-defer] )); then
  fpath+=( "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-zsh-defer" )
  source "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-romkatv-SLASH-zsh-defer/zsh-defer.plugin.zsh"
fi
fpath+=( "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zdharma-continuum-SLASH-fast-syntax-highlighting" )
zsh-defer source "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-zdharma-continuum-SLASH-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
fpath+=( "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-agkozak-SLASH-zsh-z" )
source "$HOME/.cache/antidote/https-COLON--SLASH--SLASH-github.com-SLASH-agkozak-SLASH-zsh-z/zsh-z.plugin.zsh"

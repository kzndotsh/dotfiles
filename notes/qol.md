## Create common misc/personal directories

`cd ~ && mkdir repos build projects screenshots dev vbox`

## Create default directories

`sudo pacman -Syu --noconfirm xdg-user-dirs`

```
sudo tee /etc/xdg/user-dirs.defaults > /dev/null << EOF
DESKTOP=desktop
DOWNLOAD=downloads
TEMPLATES=templates
PUBLICSHARE=public
DOCUMENTS=docs
MUSIC=music
PICTURES=pictures
VIDEOS=videos
EOF
```

`xdg-user-dirs-update --force`

# Replace bash with zsh

## Install zsh

`sudo pacman -Syu --noconfirm zsh`

## Install OMZ

`sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`

### install zsh-completions

`git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions`

`fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src`

### install zsh auto suggestions

`git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions`

`echo "source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc`

`source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh`

### install zsh syntax highlighting

`git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting`

`echo "source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ${ZDOTDIR:-$HOME}/.zshrc`

`source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh`

`exec zsh`

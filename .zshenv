export HISTSIZE=1000000
export SAVEHIST=1000000
export HISTFILE=~/.zsh_history
export HISTORY_IGNORE="(ls|bg|fg|pwd|exit|cd ..|cd -|pushd|popd)"

# PATHS
export MANPATH="/usr/local/man:$MANPATH"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:/opt/go/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.local/share/JetBrains/Toolbox/scripts:$PATH"
export PATH="$PATH:/home/kaizen/.local/share/JetBrains/Toolbox/scripts"

# Terminal
export TERMINAL=alacritty

# Browser
export BROWSER=firefox

# Editor
export VISUAL=micro
export EDITOR=micro

# Make flags
export MAKEFLAGS="-j$(nproc)"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# qt theme
export QT_QPA_PLATFORMTHEME='gtk2'
# export QT_QPA_PLATFORMTHEME='qt5ct'

export GTK_USE_PORTAL=1

export PAGER=less
export LESS='--quit-if-one-screen --ignore-case --status-column --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --no-init --window=-4'

# Colors
export CLICOLOR=1
export TERM=xterm-256color           # for common 256 color terminals (e.g. gnome-terminal)
export MICRO_TRUECOLOR=1
# export TERM=screen-256color        # for a tmux -2 session (also for screen)
# export TERM=rxvt-unicode-256color  # for a colorful rxvt unicode session

# Fix java apps for non-re-parenting window managers (like sway)
# export _JAVA_AWT_WM_NONREPARENTING=1

# gpg (for Github)
# export GPG_TTY="$(tty)"


# SSH Agent
# ssh_env="$HOME/.ssh/agent-env"
# 
# if pgrep ssh-agent >/dev/null; then
  # if [[ -f $ssh_env ]]; then
    # source "$ssh_env"
  # else
    # echo "ssh-agent running but $ssh_env not found" >&2
  # fi
# else
  # ssh-agent | grep -Fv echo > "$ssh_env"
  # source "$ssh_env"
# 
  # # Use pass(1), via wrapper script, to unlock SSH key
  # DISPLAY=99 SSH_ASKPASS="$HOME/.local/bin/ssh-askpass" ssh-add </dev/null
# fi

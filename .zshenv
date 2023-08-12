HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE=~/.zsh_history
export HISTORY_IGNORE="(ls|bg|fg|pwd|exit|cd ..|cd -|pushd|popd)"

# PATHS
export PATH=$HOME/.local/bin:$PATH
export MANPATH="/usr/local/man:$MANPATH"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:/opt/go/bin:$PATH"
export PATH="$HOME/.local/share/JetBrains/Toolbox/scripts:$PATH"


export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export QT_QPA_PLATFORMTHEME=qt5ct
export GTK_USE_PORTAL=1

export TERMINAL=alacritty
export BROWSER=firefox
export PAGER=less
export LESS='--quit-if-one-screen --ignore-case --status-column --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --no-init --window=-4'

export VISUAL=micro
export EDITOR=micro

# Colors
export CLICOLOR=1
export TERM=xterm-256color           # for common 256 color terminals (e.g. gnome-terminal)
export MICRO_TRUECOLOR=1
# export TERM=screen-256color        # for a tmux -2 session (also for screen)
# export TERM=rxvt-unicode-256color  # for a colorful rxvt unicode session


# Fix java apps for non-re-parenting window managers (like sway)
# export _JAVA_AWT_WM_NONREPARENTING=1

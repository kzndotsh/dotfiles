# .zlogin
#
# This file is sourced only for login shells. It
# should contain commands that should be executed only
# in login shells. It should be used to set the terminal
# type and run a series of external commands (fortune,
# msgs, from, etc.)
# Note that using zprofile and zlogin, you are able to
# run commands for login shells before and after zshrc.
#
# Global Order: zshenv, zprofile, zshrc, zlogin

# Compile the completion dump, to increase startup speed.
dump_file="$XDG_CACHE_HOME"/zsh/zcompdump
if [[ "$dump_file" -nt "${dump_file}.zwc" || ! -f "${dump_file}.zwc" ]]; then
  zcompile "$dump_file"
fi
unset dump_file

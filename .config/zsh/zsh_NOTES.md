<!-- # According to http://zsh.sourceforge.net/Doc/Release/Files.html, zsh startup configuration files are read in this order:
# 1. /etc/zshenv
# 2. $ZDOTDIR/.zshenv
# 3. /etc/zprofile (if shell is login)
# 4. $ZDOTDIR/.zprofile (if shell is login)
# 5. /etc/zshrc (if shell is interactive)
# 6. $ZDOTDIR/.zshrc (if shell is interactive)
# 7. /etc/zlogin (if shell is login)
# 8. $ZDOTDIR/.zlogin (if shell is login)
#
# If ZDOTDIR is unset, HOME is used instead. -->

# Every shell. Always

/etc/zshenv

# Every shell. Avoidable if passing flag -f to zsh

~/zshenv

# If it's a login shell.

/etc/zprofile
~/zprofile

# If it is an interactive shell

/etc/zshrc
~/zshrc

# If it is a login shell

/etc/zlogin
~/zlogin

zshenv

This file is sourced by all instances of Zsh, and thus, it should be kept as small as possible and should only define environment variables.

zprofile

This file is similar to zlogin, but it is sourced before zshrc. It was added for KornShell fans. See the description of zlogin below for what it may contain.

zprofile and zlogin are not meant to be used concurrently but can be done so.

zshrc

This file is sourced by interactive shells. It should define aliases, functions, shell options, and key bindings.

This is the main dotzsh configuration file.

zlogin

This file is sourced by login shells after zshrc, and thus, it should contain commands that need to execute at login. It is usually used for messages such as fortune, msgs, or for the creation of files.

This is not the file to define aliases, functions, shell options, and key bindings. It should not change the shell environment.

zlogout

This file is sourced by login shells during logout. It should be used for displaying messages and the deletion of files.

---

# How to avoid parsing /etc/\* files

Unset the GLOBAL_RCS option. To do this, add unsetopt GLOBAL_RCS to /etc/zshenv or $ZDOTDIR/.zshenv or run zsh -o NO_GLOBAL_RCS. Note that if $ZDOTDIR is unset, $HOME is used instead.

When GLOBAL_RCS is unset, /etc/zprofile, /etc/zshrc, /etc/zlogin and /etc/zlogout will not be sourced.

fpath

zsh's $fpath variable is kinda like $PATH but for search paths zsh uses. One of the main things zsh uses it for is shared functions.

    A shared function is different from functions you declare in your .zshrc file.

One major difference with $fpath is that it's an array, instead of a string separated with :. Instead of saying export fpath=$ZDOTDIR/fuctions:$fpath you need to use array syntax like export fpath=($ZDOTDIR/functions $fpath) with a space between the entries. An even better option is to append to the array with fpath+=('/some/directory') so you don't delete existing paths.

Shared functions are loaded into a shell with the autoload command.

Shared function files in $fpath don't need to declare a function name or have a function definition. You should name the file for the name of the function you want to use.

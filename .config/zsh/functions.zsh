# functions.zsh

# smart cd function, allows switching to /etc when running 'cd /etc/fstab'
function cd() {
  if ((${#argv} == 1)) && [[ -f ${1} ]]; then
    [[ ! -e ${1:h} ]] && return 1
    print "Correcting ${1} to ${1:h}"
    builtin cd ${1:h}
  else
    builtin cd "$@"
  fi
}

# Better history
function h() {
  if [ -z "$*" ]; then
    history 1
  else
    history 1 | grep -E --color=auto "$@"
  fi
}

# Copies the path of given directory or file to the system or X Windows clipboard.
# Copy current directory if no parameter.
function copypath {
  # If no argument passed, use current directory
  local file="${1:-.}"

  # If argument is not an absolute path, prepend $PWD
  [[ $file = /* ]] || file="$PWD/$file"

  # Copy the absolute path without resolving symlinks
  # If clipcopy fails, exit the function with an error
  print -n "${file:a}" | clipcopy || return 1

  echo ${(%):-"%B${file:a}%b copied to clipboard."}
}


# Copies the contents of a given file to the system or X Windows clipboard
function copyfile {
  emulate -L zsh
  clipcopy $1
}

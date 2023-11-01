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


# Repo creation helper

# function create-repo() {
# 	# Get user input
# 	echo "Enter name for new repo"
# 	read REPONAME
# 	echo "Do you want to make it private? (y/n)"
# 	read -r -n PRIVATE_ANSWER
# 
# 	if [[ "$PRIVATE_ANSWER" =~ ^[Yy]$ ]]; then
# 		PRIVATE_TF=true
# 	else
# 		PRIVATE_TF=false
# 	fi
# 
# 	# Curl some json to the github API oh damn we so fancy
# 	curl -u gretzky https://api.github.com/user/repos -d "{\"name\": \"$REPONAME\", \"private\": $PRIVATE_TF}" >/dev/null
# 
# 	# first commit
# 	git init 1>/dev/null
# 	gi macos,visualstudiocode >>.gitignore 1>/dev/null
# 	print_success ".gitignore added"
# 	git add . 1>/dev/null
# 	git commit -m "initial commit" 1>/dev/null
# 	print_success "initial commit"
# 	git remote add origin https://github.com/gretzky/$REPONAME.git 1>/dev/null
# 	git push -u origin master --force 1>/dev/null
# 
# 	sleep 0.5
# 	print_success "\nRepo created"
# 	print_in_cyan "You can view your new repo at https://github.com/gretzky/$REPONAME.git"
# }

#!/bin/bash

# Quickly totally remove a git submodule. Since this takes a few
# steps, create a custom script to do this.

# See:
#  https://stackoverflow.com/questions/1260748/how-do-i-remove-a-submodule/36593218#36593218
#  https://gist.github.com/myusuf3/7f645819ded92bda6677

submodule_path=$1

[ -d "$submodule_path" ] || (echo 'Specify valid submodule path as first parameter' && exit 1)

# Remove the submodule entry from .git/config
echo "Deinitializing submodule $submodule_path"
git submodule deinit -f $submodule_path

# Remove the submodule directory from the superproject's .git/modules directory
echo "Removing .git/modules for $submodule_path"
rm -rf .git/modules/$submodule_path

# Remove the entry in .gitmodules and remove the submodule directory located at path/to/submodule
echo "Removing files for $submodule_path"
git rm -rf $submodule_path

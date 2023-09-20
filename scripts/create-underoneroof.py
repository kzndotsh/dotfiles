#!/usr/bin/python
'''
Description
===========
This is a script to knit several repositories into one using a git subtree
strategy.
This script creates a directory `underoneroof` in the same location as this script,
which then contains each repository in a subdirectory of that, e.g.
* underoneroof/repo1
* underoneroof/repo2
Reference
=========
The git subtree merging strategy at the link below was used.
https://www.kernel.org/pub/software/scm/git/docs/howto/using-merge-subtree.html
This was also a very useful reference, though the exact merging strategy of
checking out each remote branch first (in the base directory) was a source of
merge conflicts in common files like README.md and .gitignore.
https://git-scm.com/book/en/v1/Git-Tools-Subtree-Merging
Basic Usage
===========
`$ python create_repo.py`
Output:
'underoneroof' directory (local)
To rerun, first:
`$ rm -rf underoneroof`
Detailed Usage
==============
If you `cd` into the above directory after running the script, you can run any
git commands you like, to inspect or modify the state of the repository. This
script's output is totally local to your machine, until it is put on Github and
shared, so consider it a scratchpad.
Removing the 'underoneroof' directory is required if you wish to modify and/or
re-run this script.
At the top of the script, there is a dict, `repos`, which can be modified to
change which repos are included, and what their branches and directories are
named in the new container repo.
The resulting 'underoneroof' repository will have the git history of all of the
repos combined into one. Since this is a subtree merge, there is also the
possibility of continuing to maintain the code in both places-- both here and in
the original repo(s), as merges can be performed in both directions. However, it
should also be possible to just neglect the original repository and continue all
development in this repo.
Github
======
Putting the resulting repository on github is not part of this script, but
should be an easy task.
Limitations
===========
One script limitation is that it will only merge master branches from each repo,
but other branches can be merged later using the subtree strategy, or repo
maintainers can ensure that all relevant changes are part of the master branch
before running the script.
'''

import logging
import os.path
import shlex

from os import chdir, makedirs
from subprocess import call


repos = {
        'repo1': 'git@github.com:myorg/repo1.git',
        'repo2': 'git@github.com:myorg/repo2.git',
        'repo3': 'git@github.com:myorg/repo3.git',
}

def main(*args):
    logging.info('Starting...')
    curr_path = os.path.dirname(os.path.abspath(__file__))
    makedirs(os.path.join(curr_path, 'underoneroof'))
    chdir(os.path.join(curr_path, 'underoneroof'))
    with open('README.md', 'w') as readmefile:
        readmefile.write("Under One Roof\n=========")
    call_('git init')
    call_('git add README.md')
    call_('git commit -m "Initial commit"')
    logging.info('Made initial commit...')

    for nickname, path in repos.items():
        logging.info('Adding subtree {}'.format(nickname))
        add_subtree(nickname, path)

    logging.info('Done.')

def add_subtree(nickname, path):
    remote_name = '{}_remote'.format(nickname)

    call_('git remote add {} {}', remote_name, path)
    call_('git fetch {}', remote_name)
    call_('git merge -s ours --no-commit --allow-unrelated {}/master', remote_name)
    call_('git read-tree --prefix={}/ -u {}/master', nickname, remote_name)
    call_('git commit -m "Merge {} as subdirectory {}"', remote_name, nickname)

def call_(*args):
    return call(shlex.split(args[0].format(*args[1:])))


if __name__ == '__main__':
    main()

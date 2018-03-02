#!/bin/bash
#
# Script to automatically set up symlinks for existing hooks.
#
#-----------------------------------------------------------------------------#

repositoryTopLevelPath="$(git rev-parse --show-toplevel)"
hookGitFolder=$repositoryTopLevelPath/.git/hooks
hookDistributedFolder=$repositoryTopLevelPath/hooks

cd $hookGitFolder

# Here we rely on the fact that in the "hooks" folder the executable files are only this
# script together with all the hooks that will then be used. It sounds reasonable.
for hook in $(find $hookDistributedFolder -maxdepth 1 -perm -111 -type f -printf "%f\n"); do
    #We have to skip this executable file
    if [ $hook != $(basename $BASH_SOURCE) ]; then
        ln -s -f ../../hooks/$hook $hook
    fi
done

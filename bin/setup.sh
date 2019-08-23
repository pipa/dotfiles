#!/usr/bin/env bash

dir=$(readlink -f ${BASH_SOURCE[0]}); dir=${dir%/bin/*}

# kill dead symlinks
find -L $HOME -maxdepth 1 -type l -delete

# put symlinks for dotfiles in place
${dir}/bin/dot-link-files

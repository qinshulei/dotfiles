#!/bin/bash -e
cd "$(dirname "$0")"
DOTFILES_ROOT=$(pwd -P)

# add qinshulei dotfiles
for lib_or_alias in $(ls ${DOTFILES_ROOT}/shell/*); do
    source ${lib_or_alias}
done

export PATH="${DOTFILES_ROOT}/bin:$PATH"

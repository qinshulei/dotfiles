#!/bin/bash -e
cd "$(dirname "$0")"
DOTFILES_ROOT=$(pwd -P)

# TODO: install vendor tools
# install by wget and oneline commandline.
mkdir -p "${DOTFILES_ROOT}/vendor/bin"
for install_script in $(ls ${DOTFILES_ROOT}/vendor/install-*.sh); do
    pushd "${DOTFILES_ROOT}/vendor/bin" > /dev/null
    ${install_script}
    popd > /dev/null
done

# add qinshulei dotfiles
for lib_or_alias in $(ls ${DOTFILES_ROOT}/shell/*); do
    source ${lib_or_alias}
done

# export bin and vendor/bin
export PATH="${DOTFILES_ROOT}/bin:${DOTFILES_ROOT}/vendor/bin:$PATH"

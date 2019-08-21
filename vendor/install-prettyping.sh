#!/bin/bash -e

if [ ! -f prettyping ]; then
    rm -rf prettyping.git || true
    git clone --depth 1 https://github.com/denilsonsa/prettyping.git prettyping.git
    ln -s prettyping.git/prettyping prettyping
    chmod a+x prettyping
fi

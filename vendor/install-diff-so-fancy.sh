#!/bin/bash

if [ ! -f diff-so-fancy ]; then
    rm -rf diff-so-fancy || true
    wget https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy
    chmod a+x diff-so-fancy
fi

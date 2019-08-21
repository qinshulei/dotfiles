#!/bin/bash -x

# start fcitx input service
nohup /usr/bin/fcitx-autostart 2>&1 >/dev/null &

# start synergy service
nohup /usr/bin/synergy 2>&1 >/dev/null &

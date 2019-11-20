#!/bin/bash

remote_name=${1:-"common-122"}
ip=$(echo "${remote_name}" | awk -F'-' '{print $2}')

sudo mkdir -p /mnt/${remote_name}
sudo umount /mnt/${remote_name}
sudo sshfs -o allow_other -o idmap=user -o uid=1000 -p 12026 ci@192.168.67.${ip}:/home/ci /mnt/${remote_name}

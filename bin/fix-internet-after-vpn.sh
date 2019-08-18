#!/bin/bash

gatway_ip=$1

sudo route del -net 0.0.0.0/1
sudo route del -net 128.0.0.0/1
sudo route add -net 192.168.0.0/16 gw ${gatway_ip}

#!/bin/bash

# sudo cat /etc/sysctl.conf | grep net.ipv4.ip_forward
# net.ipv4.ip_forward=1

sudo iptables -t nat -A POSTROUTING -j MASQUERADE
sudo iptables -t nat -A PREROUTING -d 192.168.0.62 -p tcp --dport 3128 -j DNAT --to 192.168.67.10:3128

#!/usr/bin/env bash
# Updating apt-get and upgrading your system. 
sudo apt-get update && sudo apt-get upgrade -y

# Installing clamav. 
sudo apt-get install -y clamav clamav-daemon libclamunrar7

# Enablinb clamav service. 
sudo systemctl enable clamav-daemon

sudo systemctl restart clamav-daemon

# Setting up and kicking off first clamav scan.
sudo bash -c 'echo "ExcludePath ^/sys/" >> /etc/clamav/clamd.conf'
sudo clamdscan --fdpass /
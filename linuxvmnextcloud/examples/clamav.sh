#!/usr/bin/env bash
echo "Updating apt-get and upgrading your system. Please wait."
sudo apt-get update && sudo apt-get upgrade -y

echo "Installing clamav. Please wait."
sudo apt-get install -y clamav clamav-daemon libclamunrar7

echo "Enablinb clamav service. Please wait."
sudo systemctl enable clamav-daemon

sudo systemctl restart clamav-daemon

echo "Setting up and kicking off first clamav scan. Please wait."
sudo bash -c 'echo "ExcludePath ^/sys/" >> /etc/clamav/clamd.conf'
sudo clamdscan --fdpass /
#!/usr/bin/env bash
sudo apt-get install -y clamav clamav-daemon libclamunrar7

sudo freshclam

sudo systemctl enable clamav-daemon

sudo systemctl start clamav-daemon

sudo clamdscan -r /home
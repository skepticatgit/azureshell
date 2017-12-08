#!/usr/bin/env bash
sudo apt-get install clamav clamav-daemon

sudo freshclam

sudo systemctl enable clamav-daemon

sudo systemctl start clamav-daemon

sudo clamdscan -r /home
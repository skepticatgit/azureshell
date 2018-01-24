#!/usr/bin/env bash

#Step 1: Launch guest OS
#Step 2: Add shared folder from Virtualbox menu Devices → Shared Folders. A dialog will show up. In this dialog you can specify which folder from your Windows system you want to share with your Ubuntu. Press the button with the + symbol to add a new shared folder in the list. You will have to specify a Folder Name for each folder you add.
#Step 3: In guest OS

sudo mkdir /home/<USERNAME>/windows-share
sudo mount -t vboxsf <SHARENAME> /home/<USERNAME>/windows-share
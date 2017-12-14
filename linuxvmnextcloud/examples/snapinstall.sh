#!/usr/bin/env bash
# Source: https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-nextcloud-on-ubuntu-16-04
# download the Nextcloud snap package and install it on the system
# this is the recommended way: sudo snap install nextcloud
# to update snap installation: sudo snap refresh nextcloud --channel=stable/pr-388 
adminId=<SET_HERE>
adminPw=<SET_HERE>
dnsName=<SET_HERE>

sudo snap install --stable nextcloud # to get stable 12.0.4

# confirm that the installation process was successful by listing the changes associated with the snap
snap changes nextcloud

#  see what snap "interfaces" this snap defines
snap interfaces nextcloud

# pass in a username and a password as arguments
sudo nextcloud.manual-install $adminId $adminPw

# add an entry for our server's domain name or IP address
sudo nextcloud.occ config:system:set trusted_domains 1 --value=$dnsName

# check trusted domains
sudo nextcloud.occ config:system:get trusted_domains

# make your Nextcloud login page publicly accessible
sudo ufw allow 80,443/tcp

# request a Let's Encrypt certificate and follow steps
sudo nextcloud.enable-https lets-encrypt
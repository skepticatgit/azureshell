---
title: Nextcloud server with docker compose on Azure
description: Creating a multi-container personal cloud server with docker-compose 
author: skepticatgit
tags: Azure, Docker, Nextcloud, SSL
date_published: 2017-09-08
---
## Objectives

1. Provision Ubuntu VM on Azure
1. Configure VM back up to Azure backup vault
1. Set-up Azure DNS zone
1. Register custom domain name with Godaddy.com
1. Deploy nextcloud with docker containers, redis cache, MariaDB and auto renewing Letsencrypt SSL certificates
1. Enable data, contacts and calendar sync with desktop client and iOS app

## Credit

- [Pradeep Cheekatla](https://stackoverflow.com/users/8188433/pradeep-cheekatla), Technical Support Engineer at Microsoft for his [Stackoverflow instructions](https://stackoverflow.com/questions/45449401/configuring-a-custom-domain-name-for-an-azure-vm-and-godaddy) about Azure DNS Zone set-up 

## Solution Benefits

1. Privacy: This could be consider de-googlification of your storage, contacts and calendar sync
1. The solution is scalable as it is based on 7 independent containers
1. Highly portable
1. Components are updated independantly
1. SSL/TLS encryption is enabled and renewed automatically via free Letsencrypt certificates 

## Pre-requisites

1. Azure subscription. You can get started with a [free account](https://azure.microsoft.com/en-us/free).

## Costs

This tutorial uses billable components of Azure Cloud. Use the [Azure Pricing
Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) to estimate the costs for your usage.
   1. [DNS Zone pricing](https://azure.microsoft.com/en-us/pricing/details/dns/)
   1. [Ubuntu D1_V2 VM pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/)
   1. [Backup Vault pricing](https://azure.microsoft.com/en-us/pricing/details/backup/)
      - [Storage blob cost of backup files](https://azure.microsoft.com/en-us/pricing/details/storage/blobs/)
   1. [Data egress pricing](https://azure.microsoft.com/en-us/pricing/details/bandwidth/) of your downloaded sync. Uploads to Azure are free.

## Architecture components
![Architecture diagram](https://github.com/skepticatgit/tutorials/blob/master/dockernextcloud/images/dockernextcloud.png)
1. Domain name hosting at [Godaddy.com](https://www.godaddy.com)
1. Ubuntu [VM on Azure](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/Canonical.UbuntuServer?tab=PlansAndPrice)
1. [DNS Zone](https://docs.microsoft.com/en-us/azure/dns/dns-overview) on Azure
1. [Letsencrypt](https://letsencrypt.org/) certificate authority
1. [Backup vault](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-backup-vms) for Azure VM
1. App containers orchestrated via [docker-compose.yml](https://docs.docker.com/compose/)
   - [Nginx reverse proxy](https://github.com/jwilder/nginx-proxy) by jwilder
   - [Letsencrypt](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) by JrC's
   - [Nginx Web Server](https://hub.docker.com/_/nginx/)
   - [Nextcloud FPM](https://github.com/nextcloud/docker/tree/master/12.0/fpm) app server
   - [Redis](https://hub.docker.com/_/redis/) cache
   - [MariaDB](https://hub.docker.com/_/mariadb/)
   - [Collabora](https://hub.docker.com/r/collabora/code/)

## Step by step guide
### I. Ubuntu VM set-up
1. Create Ubuntu Server VM on Azure
   - Follow the steps outlined in [this tutorial](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal)
   - Pick D1_V2 machine that gives you one core and 3.5GB with local SSDs: persistent is /dev/sda and ephemeral is /dev/sdb
   - Chose one of the 38 (as of this writing) Azure regions closer to your location
   - You won't need to install nginx on the VM directly, we will use docker engine and docker-compose for that
   - Optional - limit IP range for SSH connections: Browse to the resource group of the VM, click on Network Security Group (NSG) and then Inbound rules, adjust SSH rule per your IP/range

2. Configure static IP
   - While in Azure Portal, navigate to the resource group where you put your VM
   - Navigate to public IP component in the resource group. It will typically have a name as VMNAME_ip
   - Click on the configuration menu and select "Static" then "Save". Write it down as you will need it during DNS Zone set-up step
   - Optional: specify a DNS prefix so that you can ssh to your VM via **dnsPrefix.azureRegion**.cloudapp.azure.com where **dnsPrefix** is your chosen unique VM name and **azureRegion** is the location you have chosen to deploy it

### II. Purchase a custom domain name at [Godaddy.com](https://www.godaddy.com)
For the purposes of this tutorial we will assume you have registered `<YOURSITE>.com`

### III. Configure Azure DNS Zone 
In order for your custom domain name to be resolved to the static IP of your VM, we need to configure Azure DNS Zone. Steps below are a copy and paste from [Pradeep Cheekatla's](https://stackoverflow.com/users/8188433/pradeep-cheekatla) Stackoverflow [instructions](https://stackoverflow.com/questions/45449401/configuring-a-custom-domain-name-for-an-azure-vm-and-godaddy). **Note: Name server update sometime takes hours.**
1. To get DNS addresses, you need create DNS zones with your domain name.
   - Go to Azure Portal => New => search for **DNS zones** => Create DNS zones
   - Specify Name = `<YOURSITE>.com`, Subscription, Resource Group, and Location
2. Once Azure DNS zones created you can see four Name Servers.
```
- ns1-06.azure-dns.com
- ns2-06.azure-dns.net
- ns3-06.azure-dns.org
- ns4-06.azure-dns.info
```
3. Go to GoDaddy control panel and click on the DNS entry for your domain
4. Change the Nameservers by choosing your new nameserver type as `Custom`. Copy and paste the Name Servers from Azure DNS to GoDaddy. Make sure there are no trailing periods after each name server entry.
5. Open Created DNS Zones and add a record set
```
- Name: www
- Type: A
- TTL: 1 Hours
- IP ADDRESS: Give IP Address of the VM from step I.2 above.
```
### IV. Install docker engine and docker compose on the VM
Docker CE installation official instructions are [here](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/)

```
ssh <User_ID>@<VM_IP_ADDRESS>
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
Verify that the key fingerprint is 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88.
```
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce
```
Verify it was installed correctly
```
sudo docker run hello-world
```
Install docker compose, 1.16.1 as of this writing. Check for the latest release [here](https://github.com/docker/compose/releases).
```
curl -L "https://github.com/docker/compose/releases/download/1.16.1/docker-compose-$(uname -s)-$(uname -m)" > ./docker-compose
sudo mv ./docker-compose /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose

```
### V. Check the name servers and DNS zone were properly set-up
We will ssh to the machine and launch simple [nginx docker](https://hub.docker.com/_/nginx/) container to make sure we can see our custom domain name resolved to the VM IP.
```
ssh <VM_USER_ID>@<VM_IP_ADDRESS>
sudo docker run --name tmp-nginx-container -d -p 80:80 nginx
```
Check which containers you have running
```
sudo docker ps -a
```
Open browser on your client machine and you should be able to see nginx welcome page via
1. VM IP address (from "Public IP address" setting in Azure Portal)
2. Custom DNS prefix name as in **dnsPrefix.azureRegion**.cloudapp.azure.com, where **dnsPrefix** is your chosen unique VM name and **azureRegion** is the location you have chosen to deploy it to
3. `www.<YOURSITE>.com` - the final check for your GoDaddy hosted domain name to resolve to the IP address name of your VM on Azure

Let's clean up nginx container if your test above was successful
```
sudo docker stop <container_id>
sudo docker rm <container_id>
```

### VI. Docker compose set-up
When you ssh to Azure Ubuntu VM, you will land in `/home/<VM_USER_ID>`. For your docker-compose project let's set-up the sub folder.
```
ssh <User_ID>@<VM_IP_ADDRESS>
mkdir nextcloud
cd nextcloud
```
Next, we will create four files
1. [.env](https://github.com/skepticatgit/tutorials/blob/master/dockernextcloud/examples/.env) with environment variables
1. [docker-compose.yml](https://github.com/skepticatgit/tutorials/blob/master/dockernextcloud/examples/docker-compose.yml) - the template file that will orchestrate our app
1. [nginx.conf](https://github.com/skepticatgit/tutorials/blob/master/dockernextcloud/examples/nginx.conf) nginx web server configuration file
1. [uploadsize.conf](https://github.com/skepticatgit/tutorials/blob/master/dockernextcloud/examples/uploadsize.conf) nextcloud configuration entry to control upload file size
```
touch .env
touch docker-compose.yml
touch nginx.conf
touch uploadsize.conf
```
`.env` will have four entries. Let's open the file and update these entries
```
nano .env
DOMAIN=
EMAIL=
MYSQL_ROOT_PW=
MYSQL_USER_PW=
```
Ctrl O
Ctrl X
Where `DOMAIN` is the `www.<YOURSITE>.com` you registered with GoDaddy.com, `EMAIL` is admin email account and finally MySQL database passwords. Repeat the process with `docler-compose.yml`, `nginx.conf` and `uploadsize.conf` files using nano text editor. While we are in the dev/test mode, we will add this entry to the **nextcloud_webserver** environment section
```
- ACME_CA_URI=https://acme-staging.api.letsencrypt.org/directory
```
This will direct letsencrypt certificate authority to use non production entity.

Now, let's inspect the contents of `docker-compose.yml`. Docker compose functionality is beyond this tutorial, but you can read this [article](https://docs.docker.com/compose/overview/) to better understand the mechanics.

All the data including database and config files will be persisted between docker updates as we are using docker-compose volumes. See the section
```
volumes:
      - ./proxy/conf.d:/etc/nginx/conf.d
      - ./proxy/vhost.d:/etc/nginx/vhost.d
      - ./proxy/html:/usr/share/nginx/html
      - ./proxy/certs:/etc/nginx/certs:ro
      - /var/run/docker.sock:/tmp/docker.sock:ro
```
### VII. Docker compose operation
Let's make sure that we have all four files in `/home/<VM_USER_NAME>/nextcloud`
```
ls -la
```
1. You might need to create the external network first
```
sudo docker network create nginx-proxy
```
2. To start your 7 container application, we will issue this command. **Make sure you are in the working folder** where you have required 4 files including docker-compose.yml
```
sudo docker-compose up -d
```
3. To troubleshoot and review logs of all your containers
```
sudo docker-compose logs
```
Alternatively you could specify logs of a specific container by running this command
```
sudo docker logs <container_name>
```
These are the container names as defined by **docker-compose.yml**
   - proxy
   - letsencrypt-companion
   - nextcloud_webserver
   - nextcloud_fpm
   - db
   - redis
   - collabora
4. To stop your solution, while preserving the volume data
```
sudo docker-compose down
```
While you are in a dev/test mode, you might want to clean up the contents of the docker volumes. Be careful and **don't use it in prod** as this will whipe out your data and reset config.
```
sudo docker-compose down -v
```  
5. Updating your solution is accomplished via `docker-compose pull`. I highly suggest to test the new containers in the test environment before updating your prod.
```
sudo docker-compose pull
sudo docker-compose up -d
```
Open a browser and point to `www.<YOURSITE>.com` you registered with GoDaddy.com. You should see nextcloud welcome screen to perform a [first time set-up](https://docs.nextcloud.com/server/12/admin_manual/installation/installation_wizard.html).

![nextcloud screen](https://docs.nextcloud.com/server/12/admin_manual/_images/install-wizard-a.png)

6. Switch back to ssh session, bring down with `sudo docker-compose down` and update the **letsencrypt** to production certificate authority by commenting out **ACME_CA_URI** line
```
sudo docker-compose down
nano docker-compose.yml
# - ACME_CA_URI=https://acme-staging.api.letsencrypt.org/directory
```
Ctrl O
Ctrl W

7. Restart the docker-compose
```
sudo docker-compose up -d
```
8. You can verify the certificate quality via Qualys [SSL Server Test](https://www.ssllabs.com/ssltest/)

Mine passed with "A" grade
![Qualys test results](https://github.com/skepticatgit/tutorials/blob/master/dockernextcloud/images/Qualys.png)

### VIII. Initial user account and desktop client set-up
Please refer to the following [official installation guide](https://docs.nextcloud.com/server/12/admin_manual/installation/installation_wizard.html).
1. Open a browser and point to `www.<YOURSITE>.com` you registered with GoDaddy.com. 
You should see nextcloud welcome screen to perform a [first time set-up](https://docs.nextcloud.com/server/12/admin_manual/installation/installation_wizard.html).
Check that nginx has forwarded you to secure `https` URL.

2. Enter the following information
   - admin account ID
   - admin account password
   - Click on storage and database and specify
      - Data folder (leave deafult): `/var/www/html/data`
	  - MySQL root ID: `root`
	  - MySQL root password: 
	  - MySQL DB name: `nexcloud`
	  - MySQL host: `db:3306`

![nextcloud data and db](https://docs.nextcloud.com/server/12/admin_manual/_images/install-wizard-a1.png)

3. Once you are logged into the admin account, go ahead and create a non admin group and a first user account under which you will set-up file, photo, contacts and calendar sync.	  
4. Download the [nextcloud client](https://nextcloud.com/install/#install-clients) and install on your desktop.
Follow these [official instructions](https://docs.nextcloud.com/server/12/user_manual/)
   - You will specify `https://www.<YOURSITE>.com` as your nextcloud URL
   - Provide your user_id and password that you specified in step 2 above. Happy syncing!

### IX. iOS mobile client set up
1. Download the [following app](https://itunes.apple.com/us/app/nextcloud/id1125420102?mt=8) from the app store
2. Launch the iOS app once installed and
   - You will specify `https://www.<YOURSITE>.com` as your nextcloud URL
   - Provide your user_id and password that you specified in step 2 above. Happy syncing!
3. Follow [these steps](https://docs.nextcloud.com/server/12/user_manual/pim/sync_ios.html) to sync your contacts and calendar information
   - Make sure to specify **port 443** for TLS encryption as well as `https://` URL address 

### X. Post installation steps and maintenance
1. VM resource utilization

While we were in dev/test mode, we could monitor resource utilization on the VM by variety of Linux tools. I typically use `htop`, which is very light weight
```
sudo apt-get install htop -y
htop
```   
Press F10 to exit. For a one/two users 1 core and 3.5GB of RAM is sufficient.

2. Make sure to configure unattended security upgrades for Ubuntu

See the official [instructions here](https://help.ubuntu.com/lts/serverguide/automatic-updates.html).
Once installed, you can adjust which upgrades are applied automatically.
```
sudo apt-get install unattended-upgrades -y
nano /etc/apt/apt.conf.d/50unattended-upgrades
```

3. Install clamav anti-malware

Follow [these instructions](https://help.ubuntu.com/community/ClamAV).
```
sudo apt-get install clamav clamav-daemon
sudo freshclam
```
Perform a fresh scan
```
sudo clamdscan -r /home
```
Enable clamav-daemon with systemctl
```
sudo systemctl enable clamav-daemon
sudo systemctl start clamav-daemon
sudo systemctl status clamav-daemon
```
Finally let's set-up daily scans with clamdscan via cron.
```
crontab -e
00 00 * * * clamdscan -r /home
```
4. Disable SSH access in Azure Portal
   - Browse to the resource group of the VM, click on Network Security Group (NSG) and then Inbound rules, delete SSH rule
   - Optional: You might want to limit incoming IP range for ports 443 and 80
   - Optional: VM can be placed on a custom VNET and it will be only reachable there or via VNET peering. See this topic for [advanced set-up](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/network-overview).

5. Configure VM backups

Azure VMs are backed up using [recovery services vault](https://docs.microsoft.com/en-us/azure/backup/backup-azure-arm-vms). You can manage backups via [Azure portal](https://docs.microsoft.com/en-us/azure/backup/backup-azure-manage-vms).
   - Within portal, navigate to your VM
   - Click on the backups in the left **settings** blade
   - Configure DailyPolicy. I suggest to maintain at least 7 daily and 4 weekly backups.
      - [Backup Vault pricing](https://azure.microsoft.com/en-us/pricing/details/backup/)
      - [Storage blob cost of backup files](https://azure.microsoft.com/en-us/pricing/details/storage/blobs/)

6. VM monitoring via Azure portal
	- Within portal, navigate to your VM
    - Click on the **Metrics** under **Monitoring** section of the left panel
	- You can also set-up **Alert rules** under **Monitoring** section of the left panel

7. Last, but not the least, client side encryption

I highly suggest setting up [True Crypt 7.1a](https://www.grc.com/misc/truecrypt/truecrypt.htm)	containers and syncing them via Nextcloud. While you have achieved privacy and security by running Nextcloud VM, client side encryption is an additional level of security. One of the drawbacks with encrypted file containers is that Nextcloud currently does not support diffirential (delta) sync. Thus everytime time stamp of the encrypted file changes, Nextcloud will perform comlete resync.

## MIT License

Copyright (c) [2017] [Andrei Fateev]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
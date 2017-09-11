---
title: Nextcloud server with docker containers on Azure VM 
description: Creating a multi-container personal cloud server with docker-compose 
author: skepticatgit
tags: Azure, Docker, Nextcloud, SSL
date_published: 2017-09-08
---
## Objectives

1. Provision Ubuntu VM on Azure
1. Set-up Azure DNS zone
1. Register custom domain name with Godaddy.com
1. Deploy nextcloud with docker containers, redis cache, MariaDB and auto renewing Letsencrypt SSL certificates
1. Enable data, contacts and calendar sync with iOS app

## Credit

- [Pradeep Cheekatla](https://stackoverflow.com/users/8188433/pradeep-cheekatla), Technical Support Engineer at Microsoft for his [Stackoverflow instructions](https://stackoverflow.com/questions/45449401/configuring-a-custom-domain-name-for-an-azure-vm-and-godaddy) about Azure DNS Zone set-up 

## Solution Benefits

1. Privacy: This could be consider de-googlification of your storage, contacts and calendar sync
1. The solution is scalable as it is based on 7 independent containers
1. Highly portable
1. Components are updated independantly
1. SSL is enabled and renewed automatically via free Letsencrypt certificates 

## Pre-requisites

1. Azure subscription. You can get started with a [free account](https://azure.microsoft.com/en-us/free).

## Costs

This tutorial uses billable components of Azure Cloud. Use the [Azure Pricing
Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) to estimate the costs for your usage.

## Architecture components

1. Domain name hosting at [Godaddy.com](https://www.godaddy.com)
1. Ubuntu [VM on Azure](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/Canonical.UbuntuServer?tab=PlansAndPrice)
1. [DNS Zone](https://docs.microsoft.com/en-us/azure/dns/dns-overview) on Azure
1. [Letsencrypt](https://letsencrypt.org/) certificate authority
1. [Backup vault](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-backup-vms) for Azure VM
1. App containers orchestrated via [docker-compose.yml](https://docs.docker.com/compose/)
- [Nginx reverse proxy](https://github.com/jwilder/nginx-proxy) by jwilder
- [Nextcloud FPM server](https://github.com/nextcloud/docker/tree/master/12.0/fpm)
- [Letsencrypt](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) by JrC's
- [Redis](https://hub.docker.com/_/redis/) cache
- [MariaDB](https://hub.docker.com/_/mariadb/)
- [Collabora](https://hub.docker.com/r/collabora/code/)

## Step by step guide
### Ubuntu VM set-up
1. Create Ubuntu Server VM on Azure
- Follow the steps outlined in [this tutorial](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal)
- Pick D1_V2 machine that gives you one core and 3.5GB with local SSDs: persistent is /dev/sda and ephemeral is /dev/sdb
- You won't need to install nginx on the VM directly, we will use docker engine and docker-compose for that
- Optional - limit IP range for SSH connections: Browse to the resource group of the VM, click on Network Security Group (NSG) and then Inbound rules, adjust SSH rule per your IP or range

2. Configure static IP
- While in Azure Portal, navigate to the resource group where you put your VM
- Navigate to public IP component in the resource group. It will typically have a name as VMNAME_ip
- Click on the configuration menu and select "Static" then "Save". Write it down as you will need it during DNS Zone set-up step
- Optional: specify a DNS prefix so that you can ssh to your VM via dnsPrefix.azureRegion.cloudapp.azure.com where dnsPrefix is your chosen unique VM name and azureRegion is the location you have chosen to deploy it

### Optional: Purchase a custom domain name at [Godaddy.com](https://www.godaddy.com)

### Configure Azure DNS Zone 
In order for your custom domain name to be resolved to the static IP of your VM, we need to configure Azure DNS Zone. Steps below are a copy and paste from [Pradeep Cheekatla's](https://stackoverflow.com/users/8188433/pradeep-cheekatla) [Stackoverflow instructions](https://stackoverflow.com/questions/45449401/configuring-a-custom-domain-name-for-an-azure-vm-and-godaddy). **Note: Name server update sometime takes hours.**
1. To get DNS addresses, you need create DNS zones with your domain name.
- Go to Azure Portal => New => search DNS zones => Create DNS zones
- Specify Name = <yoursite>.com, Subscription, Resource Group, and Location
2. Once Azure DNS zones created you can see four Name Servers.
- ns1-06.azure-dns.com
- ns2-06.azure-dns.net
- ns3-06.azure-dns.org
- ns4-06.azure-dns.info
3. Go to GoDaddy control panel and click on the DNS
4. Change the Nameservers by choose your new nameserver type as: Custom. Copy and paste the Name Servers from Azure DNS to GoDaddy. Make sure there are no trailing periods after each name server entry.
5. Open Created DNS Zones and add a record set
- Name: www
- Type: A
- TTL: 1 Hours
- IP ADDRESS: Give IP Address of the VM.

### Install docker engine and docker compose
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
## Check name servers and DNS zone were properly set-up
We will ssh to the machine and launch simple [nginx docker](https://hub.docker.com/_/nginx/) container to make sure we can see our custom domain name resolved to the VM IP.
```
ssh <User_ID>@<VM_IP_ADDRESS>
sudo docker run --name tmp-nginx-container -d -p 80:80 nginx
```
Check which containers you have running
```
sudo docker ps -a
```
Open browser on your client machine and you should be able to see nginx welcome page via
1. VP IP addresses
2. Custome DNS prefix name as in dnsPrefix.azureRegion.cloudapp.azure.com

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
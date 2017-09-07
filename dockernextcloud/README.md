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
1. Register custom domain name with Godaddy.compose
1. Deploy nextcloud with docker containers, redis cache, MariaDB and auto renewing Letsencrypt SSL certificates

## Credit

- [Pradeep Cheekatla](https://stackoverflow.com/users/8188433/pradeep-cheekatla), Technical Support Engineer at Microsoft for his [Stackoverflow instructions](https://stackoverflow.com/questions/45449401/configuring-a-custom-domain-name-for-an-azure-vm-and-godaddy) about Azure DNS Zone set-up 

## Solution Benefits

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
1. Ubuntu VM on Azure
1. DNS Zone on Azure
1. Letsencrypt certificate authority
1. Backup vault for Azure VM
1. App containers orchestrated via docker-compose.yml
- Nginx reverse proxy
- Nextcloud FPM server
- Letsencrypt
- Redis cache
- MariaDB
- Collabora

## Step by step guide
### Ubuntu VM set-up
1. Create Ubuntu Server VM on Azure
- Follow the steps outlined in [this tutorial](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal)
- You won't need to install nginx on the VM directly, we will use docker engine and docker-compose for that
- Optional - limit IP range for SSH connections: Browse to the resource group of the VM, click on Network Security Group (NSG) and then Inbound rules, adjust SSH rule per your IP or range

2. Login

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
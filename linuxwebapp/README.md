---
title: A practical guide to Docker containers
description: Creating a static website using Nginx:Alpine Docker container running on Azure Web App for Linux.
author: skepticatgit
tags: Azure, Docker, Nginx, Web App
date_published: 2017-02-28
---
## Objectives

1. Install Docker engine
1. Author a static web page
1. Create a self contained web server and site dockerfile to build its Docker image
1. Publish newly built Docker image to your Docker hub
1. Run the container in a serverless Linux Web App environment with your custom created Docker image

## Credit
-  For inspiration: [Kyle Mathews](https://www.linkedin.com/in/kylemathews/) and his [blog post](https://www.bricolage.io/hosting-static-sites-with-docker-and-nginx/)
-  For troubleshooting:  [Vadim Kacherov](https://www.linkedin.com/in/vadim-kacherov-8814667a/), awesome [Microsoft Technology Center](https://www.microsoft.com/en-us/mtc/locations/boston.aspx) architect
- [templated.co](https://templated.co/) and [purecss.io](https://purecss.io/) CSS and HTML samples

## Solution Benefits
- This solution has a lot of attractive characteristics:
- No VM or OS patching and managing headache: we will run in a serverless fully managed platform
- Nginx is a light weight web server, Alpine flavor of which will result in less than 60MB container
- Static web sites don't rely on PHP and MySQL presenting fewer attack surfaces
- Container and Web App don't have SSH enabled thus further limiting security exposure

## Before you begin
1. Azure subscription. You can get started with a [free account](https://azure.microsoft.com/en-us/free).
1. Working Ubuntu 16.04 environment. I will use a [Ubuntu LTS Server](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-linux-quick-create-portal) VM running on Azure.
1. SSH client like [putty](https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe) if you are connecting from Windows client.
1. [Putty SCP](https://the.earth.li/~sgtatham/putty/latest/w64/pscp.exe) for transfering files to a VM host.
1. [Docker hub](https://hub.docker.com/) account.
1. HTML editor. I prefer [Notepad++](https://notepad-plus-plus.org/).
1. HTML and CSS free to use sample. I liked [templated.co](https://templated.co/) and [purecss.io](https://purecss.io/).
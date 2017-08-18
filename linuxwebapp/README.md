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

## Pre-requisites
1. Azure subscription. You can get started with a [free account](https://azure.microsoft.com/en-us/free).
1. Working Ubuntu 16.04 environment. I will use a [Ubuntu LTS Server](https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-linux-quick-create-portal) VM running on Azure.
1. SSH client like [putty](https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe) if you are connecting from Windows client.
1. [Putty SCP](https://the.earth.li/~sgtatham/putty/latest/w64/pscp.exe) for transfering files to a VM host.
1. [Docker hub](https://hub.docker.com/) account.
1. HTML editor. I prefer [Notepad++](https://notepad-plus-plus.org/).
1. HTML and CSS free to use sample. I liked [templated.co](https://templated.co/) and [purecss.io](https://purecss.io/).

## Costs

This tutorial uses billable components of Azure Cloud. Use the [Azure Pricing
Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) to estimate the costs for your usage.


## Step by step guide

1. Install Docker

SSH to your VM using putty. Please follow the official Docker installation [instructions](https://docs.docker.com/engine/installation/linux/ubuntu/). Once done, check that it installed correctly by executing the following code:
```
sudo docker version
```
You should see the status returned in the [Img. 1](https://github.com/skepticatgit/tutorials/blob/master/linuxwebapp/images/01.SSH-dockerver.png?raw=true).

And finally let's check that your local instance can communicate with Docker hub by executing the following code:
```
sudo docker run hello-world
```
2. Download a sample HTML and CSS

For simplicity sake I grabbed a "Responsive Side Menu" layout and css from purecss.io. Once downloaded, extract the "pure-layout-side-menu.zip" archive into "pure-layout-side-menu" folder. [Img. 2](https://github.com/skepticatgit/tutorials/blob/master/linuxwebapp/images/02.HTMLandCSS.png?raw=true)
```
css folder
js folder
index.html
LICENSE.md
README.md
```

3. Author HTML and CSS to your heart's delight

From the [Img. 3](https://github.com/skepticatgit/tutorials/blob/master/linuxwebapp/images/03.Notepad.png?raw=true) you can see my Notepad++ window. Make sure to change links to relative folder location from "\" to "/" if you are moving from Windows to Linux.

4. Zip your site files and folders and transfer to the VM via SCP

I used 7zip which created "site.zip" of my "site" folder and its three subfolders: "css", "js" and "img" weighing 128KB. Since I am authenticating with certificate to my VM, I will need to use the [generated private key](https://verrytechnical.com/using-pscp-with-ssh-key-pair-authentication-to-transfer-files/) located on my PC. For simplicity sake let's put both the certificate and site.zip to C:\. Now let's fire up Putty SCP and transfer that archive by executing this code. [Img. 4](https://github.com/skepticatgit/tutorials/blob/master/linuxwebapp/images/04.PSCP.png?raw=true)
```
C:\pscp -i "C:\LinuxVM.ppk" C:\site.zip demouser@bes.centralus.cloudapp.azure.com:
```

5. Time to create the dockerfile

There is a good explanation of Docker construct including dockerfile at the [Digitalocean.com](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-getting-started). Once connected to your VM, let's extract the archive into "/home/site" folder on the VM. [Img. 5](https://github.com/skepticatgit/tutorials/blob/master/linuxwebapp/images/05.Unzip.png?raw=true)
```
unzip site.zip
```

5. Time to create the dockerfile

To create a simple dockerfile
```
touch dockerfile
nano dockerfile
```
Type the following in the nano window
```
FROM nginx:alpine 
COPY site /usr/share/nginx/html 
```
Since we are not starting from scratch, we will use [nginx:alpine](https://hub.docker.com/_/nginx/) Docker image that has nginx installed and config file properly set-up. **"Ctrl O"** to write out the dockerfile and **"Ctrl X"** to close it. Let's briefly look at the code in our dockerfile:

- `FROM nginx:alpine` is pulling the pre-built nginx webserver image
- `COPY site /usr/share/nginx/html/` This is where the magic happens: this line instructs builder to copy VM host "/home/site" folder content into the Docker image

6. Let's build the image

Make sure you don't skip trailing space and period at the end. "site" is the name of our image, and ":v1" version tag. [Img. 6](https://github.com/skepticatgit/tutorials/blob/master/linuxwebapp/images/06.Build.png?raw=true)
```
sudo docker build -t site:v1 .
sudo docker images
```
Note the "IMAGE ID" for your image, you will need it for the next step. [Img. 7](https://github.com/skepticatgit/tutorials/blob/master/linuxwebapp/images/07.Listimages.png?raw=true)

7. Tag and upload the image to your Docker hub
```
sudo docker tag 61d2db934309 skepticatdh/site:v1
```
Where "61d2db934309" is my image ID, "skepticatdh" is my Docker hub ID and "site:v1" name and tag of my image. [Img. 8](https://github.com/skepticatgit/tutorials/blob/master/linuxwebapp/images/07.Tag.png?raw=true)
```
sudo docker images
```
Note that we now have tagged and untagged images. We will be uploading the tagged one in the next step. Notice that our container weighs only 58MB! 

Login to your docker account. [Img. 9](https://github.com/skepticatgit/tutorials/blob/master/linuxwebapp/images/08.Login.png?raw=true)
```
sudo docker login
```
Push the image to the hub. [Img. 10](https://github.com/skepticatgit/tutorials/blob/master/linuxwebapp/images/09.Push.png?raw=true)
```
sudo docker push skepticatdh/site:v1
```
Login to your Docker hub account and check the posted image. [Img. 11](https://github.com/skepticatgit/tutorials/blob/master/linuxwebapp/images/10.Hub.png?raw=true)

8. Create Azure Linux Web App

You might want to get more background on Azure Web Apps by reading the following:

- Web Apps [Overview](https://docs.microsoft.com/en-us/azure/app-service-web/app-service-web-overview)
- Introduction to [App Service on Linux](https://docs.microsoft.com/en-us/azure/app-service-web/app-service-linux-intro)
- Creating [Linux Web App](https://docs.microsoft.com/en-us/azure/app-service-web/app-service-linux-how-to-create-a-web-app)
- App service [plans and tiers](https://docs.microsoft.com/en-us/azure/app-service/azure-web-sites-web-hosting-plans-in-depth-overview?toc=%2fazure%2fapp-service-web%2ftoc.json)

Log in with your account to [Azure portal](https://portal.azure.com/). Follow [these steps](https://docs.microsoft.com/en-us/azure/app-service-web/app-service-linux-how-to-create-a-web-app) and start provisioning the Web App. I picked Basic tier, which is not allowing auto-scaling and some other features of the Standard app tier. I will keep an eye on the logs and will step up to a bigger tier if necessary. Once you are at the Docker [container menu](https://docs.microsoft.com/en-us/azure/app-service-web/app-service-linux-using-custom-docker-image#how-to-use-a-custom-docker-image-from-docker-hub), specify "skepticatdh" which is my user ID (replace with yours) on Docker hub and "site:v1" (replace with yours) which is the name of the Docker image we created. Another setting I suggest to enable is ALWAYS ON. [Img. 12](https://github.com/skepticatgit/tutorials/blob/master/linuxwebapp/images/11.Deploy.png?raw=true)

If you create another docker image with the updated content, simply specify the new name:version and then restart the web app. [Img. 13](https://github.com/skepticatgit/tutorials/blob/master/linuxwebapp/images/12.Update.png?raw=true), [Img. 14](https://github.com/skepticatgit/tutorials/blob/master/linuxwebapp/images/13.Restart.png?raw=true)
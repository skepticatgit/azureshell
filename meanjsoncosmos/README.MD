---
title: MEAN.js google map tutorial with Cosmos DB
description: Step by step guide to perform Kirill Gavrylyuk's demo of Cosmos DB with MEAN app https://channel9.msdn.com/Shows/Azure-Friday/Introducing-Azure-Cosmos-DB
author: skepticatgit
tags: Azure, MongoDB, MEAN.js, CosmosDB
date_published: 2017-12-14
---
## Objectives

1. Install all the pre-requisites and MEAN stack on Ubuntu desktop for the demo
1. Provision Cosmos DB with MongoDB API
1. Pull scotch-io mean-google-maps application
1. Copy MongoDB collection from scotch-io tutorial into fresh Cosmos DB instance
1. Update mean-google-maps server settings to use Cosmos DB

## Credit
1. [Chris Sevilleja](https://github.com/sevilayha) for his  [MeanMapAppV2.0](https://github.com/skepticatgit/mean-google-maps) app and tutorial
1. Kirill Gavrylyuk(https://www.linkedin.com/in/kirillgavrylyuk/) for [Channel9 CosmosDB intro video](https://channel9.msdn.com/Shows/Azure-Friday/Introducing-Azure-Cosmos-DB)

## Step by step guide
### I. Ubuntu client pre-requisites and MEAN.js stack
If you are a MEAN.js developer, most likely you don't need to follow this tutorial and just skip to Kirill's video. This is targeted towards non developers who have a fresh Linux client machine. I will show you how to set up and demo Mongo API capability of Cosmos DB.

Assuming you have Ubuntu 16.04 LTS desktop or one of it's direvatives, let's cut to the chase - get and execute the script from your Linux client:
```
wget https://raw.githubusercontent.com/skepticatgit/tutorials/master/meanjsoncosmos/examples/mean-install-dependencies.sh
chmod +x mean-install-dependencies.sh
./mean-install-dependencies.sh
```

Script breakdown and explanation:
```
#install Git
sudo apt-get install git-all -y

#install MongoDB
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
sudo apt-get update
sudo apt-get install -y mongodb-org

#install node.js
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential

#install npm
sudo apt-get install -y npm

#install bower and create a sim link for compatability
npm install -g bower
sudo ln -s /usr/bin/nodejs /usr/bin/node #alternatively install legacy: apt-get install nodejs-legacy

#install bower dependencies
bower install angular-route#1.4.6
bower install angularjs-geolocation#0.1.1
bower install bootstrap#3.3.5
bower install modernizr#3.0.0

#download and install Studio 3T v5.7.2, formerly MongoChef
mkdir studio3t
cd studio3t
wget https://download.studio3t.com/studio-3t/linux/5.7.2/studio-3t-linux-x64.tar.gz
tar -xvzf studio-3t-linux-x64.tar.gz
chmod +x studio-3t-linux-x64.sh

#Launching GUI portion of MongoChef installer, specify /bin subfolder at the GUI prompt
./studio-3t-linux-x64.sh

```
### II. Git clone Google Maps created for Scotch IO Tutorial
```
mkdir projects
cd projects
git clone https://github.com/scotch-io/mean-google-maps.git
```
Now let's install from the new repository and start the server
```
cd mean-google-maps
npm install
node server
```
You should be able to point your browser now to [localhost:3000](http://localhost:3000) and the app will launch and run locally.

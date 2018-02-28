#!/usr/bin/env bash
#description	:This script installs dependencies for mean-google-maps on Ubuntu 16.04 LTS, requires su
#notes			:Tutorial is at https://scotch.io/tutorials/making-mean-apps-with-google-maps-part-i
#notes			:CosmosDB demo at https://channel9.msdn.com/Shows/Azure-Friday/Introducing-Azure-Cosmos-DB?term=mongodb%20cosmos
#author			:Andrei Fateev (github: skepticatgit; contact andf at microsoft dot com)
#date			:2017-12-05
#version		:0.1

#install Git
sudo apt-get install git-all -y

#install mongo
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

#install express and other dependecies
npm install -g express mongoose morgan body-parser method-override

#install bower and create a sim link for compatability
npm install -g bower
sudo ln -s /usr/bin/nodejs /usr/bin/node #alternatively install legacy: apt-get install nodejs-legacy

#install bower dependencies
bower install angular-route#1.4.6
bower install angularjs-geolocation#0.1.1
bower install bootstrap#3.3.5
bower install modernizr#3.0.0

#download and install Studio 3T, formerly MongoChef
mkdir studio3t
cd studio3t
wget https://download.studio3t.com/studio-3t/linux/5.7.2/studio-3t-linux-x64.tar.gz
tar -xvzf studio-3t-linux-x64.tar.gz
chmod +x studio-3t-linux-x64.sh

# Launching GUI portion of MongoChef installer, specify /bin subfolder at the prompt
./studio-3t-linux-x64.sh

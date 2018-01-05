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
1. [Kirill Gavrylyuk](https://www.linkedin.com/in/kirillgavrylyuk/) for [Channel9 CosmosDB intro video](https://channel9.msdn.com/Shows/Azure-Friday/Introducing-Azure-Cosmos-DB)

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

### III. Create CosmosDB with Mongo API 
If you already have a CosmosDB with Mongo API instance, you can skip to the export-import section.

Log into [Azure portal](https://portal.azure.com) with your credentials and 
launch the [cloud shell](https://docs.microsoft.com/en-us/azure/cosmos-db/scripts/create-mongodb-database-account-cli?toc=%2fcli%2fazure%2ftoc.json#launch-azure-cloud-shell).
Pull [this script](https://raw.githubusercontent.com/skepticatgit/tutorials/master/meanjsoncosmos/examples/createmongocosmos.sh) and execute it from the shell.
```
wget https://raw.githubusercontent.com/skepticatgit/tutorials/master/meanjsoncosmos/examples/createmongocosmos.sh
chmod +x createmongocosmos.sh
./createmongocosmos.sh
```
It should take you about 5 min to create the new instance.
Now let's get the connection string:
1. Close cloud shell
1. Browse to the newly created CosmosDB instance
1. Click on the "Quick Start" menu item in the left pane. Hint: it is located under "Overview" stack of items.
1. You will see the ".NET" tab open by default. Click on the "copy" icon next to the "Primary Conenction String". 

### IV. Connect to Scotch-IO and CosmosDB instances of Mongo
Launch Studio 3T (formerly MongoChef). If it's a new installation it will have no existing connections and you will be presented with the connection manager.
1. Click on "New conenction"
1. Click on "From URI"
1. Paste the string you copied above in Azure Portal
1. Click connect and you should see "docdb-test.documents.azure.com:10255" server amd "admin" DB with no collections.

Now lets browse to the location of the "config.js" file located where you pulled the git repo of the MEAN-GOOGLE-MAPS. You will need the connection string info:
```
mean-google-maps/app/config.js
```
Copy the string:
```
mongodb://scotch:scotchrocks@ds051853.mongolab.com:51853/mean-map-app
```
Switch back to Studio 3T (formerly MongoChef). 
1. Click on "New conenction"
1. Click on "From URI"
1. Paste without double quotes "mongodb://scotch:scotchrocks@ds051853.mongolab.com:51853/mean-map-app"
1. You should see "ds051853.mongolab.com:51853" server and "mean-map-app" MongoDB

### V. Import collection to CosmosDB
In the [video](https://channel9.msdn.com/Shows/Azure-Friday/Introducing-Azure-Cosmos-DB) Kirill uses "copy-paste collection" functionality of the Studio 3T. Somehow it has not worked for me as I was getting "An error occurred while trying to copy indices". We will perform "export-import" instead.
1. While in Studio 3T, right click on the "scotch-users" collection
1. Click on "Export collection"
1. Specify "JSON" file format
1. Next, specify top "JSON - mongo shell / Studio 3T" option
1. Specify file name as "scotch-users.json" without "mean-map-app." prefix
1. Click "Export" and verify that you have the "scotch-users.json" file in the location of your choice

Now let's import that file into your CosmosDB as a new collection.
1. While in Studio 3T, right click on empty "Collections" object under "admin" DB of your "docdb-test.documents.azure.com:10255" instance
1. Select import and specify first top option "JSON - mongo shell..."
1. Click on plus "+" icon and point to the "scotch-users.json" file 
1. Click "Next"
1. Click on "Start Import". Check the log for any errors.

### VI. Switch mean-map-app to use CosmosDB
Let's backup the "mean-google-maps/app/config.js" first as we will make a change in it:
```
cp mean-google-maps/app/config.js mean-google-maps/app/config.bkp
```
Open "mean-google-maps/app/config.js" in the editor of your choice:
1. Change "mongolab" connection name to "cosmosdb"
1. Change the string following "url" to you CosmosDB string from Azure Portal.
1. Save the file
Since we updated the connection name to "cosmosdb", we need to update it in the "server.js" file as well
Let's backup the "server.js" as we will make a change in it:
```
cp mean-google-maps/server.js mean-google-maps/server.bkp
```
Open "mean-google-maps/server.js" in the editor of your choice to change from
```
mongoose.connect(database.mongolab.url);
```
to 
```
mongoose.connect(database.cosmosdb.url);
```
Save the file. Restart the server by pressing "Ctrl C" and then type 
```
node server
```
while you are in "mean-google-maps" folder. 
Switch to the browser and reload this url: [localhost:3000](http://localhost:3000)
Now let's test out and add a new entry which will be written to CosmosDB and the app is no wiser to the fact. I specified "skepticatgit" Username.
### VII. Check your CosmosDB has the new entry
1. Switch to the portal.azure.com and navigate to your CosmosDB instance
1. Launch Data Explorer (Hint: it's under "Overview" stack of items)
1. Right click on "scotch-users" collection and launch new MongoDB Shell
1. Type the following at the prompt
```
>db["scotch-users"].find("{age:23}")
#!/bin/bash
#description	:This script requires Azure cloud shell with CLI 2.0 and it deploys CosmosDB instance with Mongo API
#notes			:Tutorial is at https://docs.microsoft.com/en-us/azure/cosmos-db/scripts/create-mongodb-database-account-cli?toc=%2fcli%2fazure%2ftoc.json#sample-script
#date			:2018-01-04
#version		:0.1

# Set variables for the new account, database, and collection
resourceGroupName='rg_myCosmosDB'
location='southcentralus'
name='docdb-test'
databaseName='docdb-mongodb-database'
collectionName='docdb-mongodb-collection' #optional

# Create a resource group
az group create \
	--name $resourceGroupName \
	--location $location

# Create a MongoDB API Cosmos DB account
az cosmosdb create \
	--name $name \
	--kind MongoDB \
	--locations "South Central US"=0 "North Central US"=1 \
	--resource-group $resourceGroupName \
	--max-interval 10 \
	--max-staleness-prefix 200

# Create a database 
az cosmosdb database create \
	--name $name \
	--db-name $databaseName \
	--resource-group $resourceGroupName

# Get the connection string for MongoDB apps
az cosmosdb list-connection-strings \
        --name $name \
        --resource-group $resourceGroupName

# Create a collection - uncomment to create
# az cosmosdb collection create \
#	--collection-name $collectionName \
#	--name $name \
#	--db-name $databaseName \
#	--resource-group $resourceGroupName

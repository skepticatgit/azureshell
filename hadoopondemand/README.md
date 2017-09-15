---
title: Big Data Clusters on Demand Tutorial
description: How to automate creation, scaling and deletion of HDInsight Spark cluster on Azure.
author: skepticatgit
tags: Azure, HDInsight, IaC, Spark, Azure CLI
date_published: 2017-07-28
---
## Objectives
1. Create a bash script for HDInsight automation
1. Provision HDInsight Spark cluster via bash script
1. Scale and delete HDInsight Spark cluster

## Credit
- Microsoft Azure [HDI Documentation](https://docs.microsoft.com/en-us/azure/hdinsight/) for process diagram
- [Ashish Thapliyal](https://www.linkedin.com/in/ashish-thapliyal-51753210/) for his [architecture diagram](https://blogs.msdn.microsoft.com/azuredatalake/2017/03/24/hive-metastore-in-hdinsight-tips-tricks-best-practices/)

## Pre-requisites

- Beginner level Linux file operation and bash knowledge
- Azure account: Follow how to set up a free account [link](https://azure.microsoft.com/en-us/free/)
- Azure Command Line Interface (CLI). Microsoft is moving to a Python based CLI 2.0, but for now let’s use [CLI 1.0](https://docs.microsoft.com/en-us/azure/cli-install-nodejs) on [Node.js](https://nodejs.org/en/). Once Node is installed simply execute from the command prompt `npm install -g azure-cli`
- A service principal as it allows much easier authentication and CLI login to your subscription. Follow [this link](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli) for SP creation tutorial
- IDE or Notepad++.
- Since we will want to persist the storage between cluster creations/deletions, let’s [set-up a resource group](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-portal) and a [storage account](https://docs.microsoft.com/en-us/azure/storage/storage-create-storage-account#create-a-storage-account) (blob and a container) in it. Make sure to note the storage account key, you will need it later.

## Costs

This tutorial uses billable components of Azure Cloud. Use the [Azure Pricing
Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) to estimate the costs for your usage. Navigate to **Data and Analytics**, then click on **HDInsight**. Adjust the number and size of VMs accordingly. Storage Account (blob) is located under **Storage**. 

## Outstanding
1. Add service principal creation script
1. Add resource group and storage account creation script

## Step by step guide

### Create two bash scripts
- [hdicreate.sh](https://github.com/skepticatgit/tutorials/blob/master/hadoopondemand/scripts/hdicreate.sh?raw=true) that will log-in into our account as a service principal and provision the cluster
- [hdidelete.sh](https://github.com/skepticatgit/tutorials/blob/master/hadoopondemand/scripts/hdidelete.sh?raw=true) that will log-in into our account as a service principal and delete the cluster
- **Optional**: provision a Linux VM or Linux serverless environment to execute cron with the scripts above

**hdicreate.sh**
```
#!/bin/bash
# A simple Azure CLI

printf “Setting up the variables... \n”
export sp=<SERVICE_PRINCIPAL_ID> # you created this in the previous step
export sppass=< SERVICE_PRINCIPAL_PW> # you created this in the previous step
export rg=<RESOURCE_GROUP_NAME> # you created this in the previous step
export storname=<STOR_ACC_NAME> # you created this in the previous step
export storkey=<STOR_KEY> # you created this in the previous step
export pass=<CLUSTER_PW>
export loc=eastus2 #East US 2 is the location
export storsku=LRS #Locally Redundant Storage for the blob
export storkind=Storage
export sparkname=<SPARK_NAME>

# Logging in with the Service Principal…
azure login --service-principal -u $sp -p $sppass --tenant Microsoft.com #your tenant is different

#Submitting request to create a new Spark cluster...
azure hdinsight cluster create -g $rg -l $loc -y Linux \
--clusterType Spark \
--version 3.6 \
--headNodeSize Standard_D3_v2 \
--workerNodeSize Standard_D3_v2 \
--workerNodeCount 2 \
--defaultStorageAccountName $storname.blob.core.windows.net \
--defaultStorageAccountKey $key \
--defaultStorageContainer defaultspark \
--userName admin \
--password $pass \
--sshUserName sshuser \
--sshPassword $pass $sparkname &

printf "Logging out the Service Principal...\n "
azure logout $sp

printf "Done. Goodbye...\n "
```

**hdidelete.sh**
```
#!/bin/bash
# A simple Azure CLI

printf “Setting up the variables... \n”
export sp=<SERVICE_PRINCIPAL_ID> # you created this in the previous step
export sppass=< SERVICE_PRINCIPAL_PW> # you created this in the previous step
export rg=<RESOURCE_GROUP_NAME> # you created this in the previous step
export sparkname=<SPARK_NAME>

# Logging in with the Service Principal…
azure login --service-principal -u $sp -p $sppass --tenant Microsoft.com #your tenant is different

printf "Deleting HDI cluster... \n "
azure hdinsight cluster delete $sparkname --resource-group $rg &

printf "Logging out the Service Principal...\n "
azure logout $sp

printf "Done. Goodbye...\n "
```
A quick script breakdown

1. Don’t forget to add “&” if you want execution in the background. Cluster creation process will take about 12 minutes.
2. Script creates a two head node and two worker node [Spark cluster](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-apache-spark-overview#next-steps)
   - This is a “frugal” Spark cluster as with 4-core/14 GB RAM [per node](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/sizes-general)
   - Spark Core. Includes 
      - Spark Core
	  - Spark SQL
	  - Spark streaming APIs
	  - GraphX
	  - MLlib
   - Ambari dashboard
   - Zookeeper
   - Anaconda
   - Livy
   - Jupyter notebook
   - Zeppelin notebook
3. The data will be committed a-sync and persisted on the blob (object storage). You can maintain inputs, outputs, Spark SQL and UDFs here and they will survive cluster deletions and scale-up / scale-down
4. (Optionally) You can create and persist meta store on the managed SQL or MySQL Azure instance

### Usage
From command line interface (like git bash) you'd execute `bash C:/hdicreate.sh` or `bash C:/hdidelete.sh` accordingly, assuming you have these files on C:\ of Windows machine.

For resizing of the clusters horizontally, adding or deleting data nodes, you'd [create script](https://github.com/skepticatgit/tutorials/blob/master/hadoopondemand/scripts/hdiresize.sh?raw=true) to execute the following:
```
azure hdinsight cluster resize $sparkname 1 --resource-group $rg #this scales cluster down to 1 data node
```
Note that by default your subscription will be limited as of this writing to [60 cores for HDInsight](https://docs.microsoft.com/en-us/azure/azure-subscription-service-limits). If you need to create a larger HDInsight cluster or multiple HDInsight clusters that together exceed your current subscription maximum, you can request that your subscription's billing limits be increased. Please open a support ticket with Support Type = Billing. Depending on the maximum nodes per subscription that you request, you may be asked for additional information that will allow us to optimize your deployment(s).

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
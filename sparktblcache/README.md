---
title: Working with Spark Cached Tables in BI Tools
description: Learn to cache large tables in memory of HDInsight Spark for fast data exploration and visualization in PowerBI.
author: skepticatgit
tags: Azure, Spark, HDInsight, PowerBI
date_published: 2017-07-06
---
This tutorial will guide you through connecting to Thrift Server via beelineand
and caching tables in Spark for subsequent exploration 
and visualization in BI tools.

## Objectives
If you worked through this [HDInsight Spark tutorial](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-apache-spark-use-bi-tools), you would learned that the "hvactemptable" table is only available in the context and current PySpark session. External tools won't be able to see it. We will need to execute "cache table" statement which we will accomplish with Beeline client and Thrift Server.

- Provision HDInsight Spark cluster
- Connect to Thrift Server via beeline client
- Cache table in memory
- Connect PowerBI to Spark cached table 

## Before you begin

1. Azure HDInsight Spark cluster. Follow this [link](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-apache-spark-jupyter-spark-sql) to create HDInsight Spark cluster.
1. Linux shell or command line interface. I am using [Ubuntu Bash](https://msdn.microsoft.com/en-us/commandline/wsl/about) on Windows.
1. Desktop BI tool like Tableau or [Power BI desktop](https://powerbi.microsoft.com/en-us/downloads/).

## Step by step guide

1. Open the shell window and SSH to the HDInsight head node

    $ssh <sshusername>@<clustername>-ssh.azurehdinsight.net

![SSH log-in](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img1.jpg?raw=true "SSH log-in")

![SSH log-in](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img2.jpg?raw=true "SSH log-in")

1. Launch beeline client
    
	$beeline
	
![Beeline](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img3.jpg?raw=true "Beeline log-in")

1. Connect to the Spark Thrift Server via JDBC driver by entering the following string and providing account credentials for the admin

    $!connect 'jdbc:hive2://<clustername>.azurehdinsight.net:443/default;ssl=true;transportMode=http;httpPath=/sparkhive2'
	
![Connect](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img4.jpg?raw=true "Beeline log-in")

HDInsight comes pre-loaded with a sample table called "hivesampletable" sitting on WASB storage.

1. List tables

    $show tables;
	
![List Tables](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img5.jpg?raw=true "List tables")

1. Let's check the time it will take to count number of all rows in the table while it is uncached for the reference.

    $select count(*) from hivesampletable;

![Uncached performance](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img6.jpg?raw=true "Uncached scan")

Operation accomplished in 16 seconds.

1. Cache the sample table in memory and then execute a one row count. You need to do this to commit the change as by default Spark performs "lazy execution".

    $cache table hivesampletable;
    $select count(1) from hivesampletable;	
	
![Execute caching](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img7.jpg?raw=true "Execute caching")	

1. Now let's compare the same row count with in-memory cached table

    $select count(*) from hivesampletable;
	
![Cached performance](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img8.jpg?raw=true "Cached scan")

Not bad: under 0.5 second! You can disconnect beeline client by executing

    $!q

1. Launch Power BI desktop and select **Get Data** -> **More**

![Launch PBI](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img9.jpg?raw=true "launch PBI")

1. Select "Azure" and "Azure HDInsight Spark (Beta)"

![PBI connector](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img10.jpg?raw=true "PBI connector")

1. Specify the Spark cluster URL as **<sparkname>.azurehdinsight.net**. I picked **DirectQuery** as it allows to leverage the underlying Spark cluster processing power and not bringing all data into Power BI model. You can read more about Direct Query [here](https://powerbi.microsoft.com/en-us/documentation/powerbi-desktop-use-directquery/).

![PBI connector - Spark URL](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img11.jpg?raw=true "PBI connector - Spark URL")

1. Let's provide the same admin credentials we used for connecting to the head node above

![PBI connector - Spark credentials](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img12.jpg?raw=true "PBI connector - Spark credentials")

11. Once connected you should be able to see the cluster and hivesampletable

![PBI editor](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img13.jpg?raw=true "PBI editor")
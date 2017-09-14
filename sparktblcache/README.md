---
title: Working with Spark Cached Tables in BI Tools
description: Learn to cache large tables in memory of HDInsight Spark for fast data exploration and visualization in PowerBI.
author: skepticatgit
tags: Azure, Spark, HDInsight, PowerBI
date_published: 2017-07-06
---
This tutorial will guide you through connecting to HDInsight Thrift Server via beeline client and caching tables in Spark for subsequent exploration and visualization in BI tools. If you worked through this HDInsight Spark [tutorial](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-apache-spark-use-bi-tools), you would learned that the "hvactemptable" table is only available in the context and current PySpark session. External tools won't be able to see it. We will need to execute "cache table" statement which we will accomplish with Beeline client and Thrift Server.

## Objectives

- Provision HDInsight Spark cluster
- Connect to Thrift Server via beeline client
- Cache table in memory
- Connect PowerBI to Spark cached table 

## Pre-requisites
1. Azure HDInsight Spark cluster. Follow this [link](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-apache-spark-jupyter-spark-sql) to create HDInsight Spark cluster.
1. Linux shell or command line interface. I am using [Ubuntu Bash](https://msdn.microsoft.com/en-us/commandline/wsl/about) or [Git Bash](https://git-scm.com/download/win) on Windows.
1. Desktop BI tool like Tableau or [Power BI desktop](https://powerbi.microsoft.com/en-us/downloads/).

## Costs

This tutorial uses billable components of Azure Cloud. Use the [Azure Pricing
Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) to estimate the costs for your usage.


## Step by step guide

1. Open the shell window and SSH to the HDInsight head node. [Img. 1](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img1.jpg?raw=true) [Img. 2](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img2.jpg?raw=true)
```
ssh <sshusername>@<clustername>-ssh.azurehdinsight.net
```

2. Launch beeline client. [Img. 3](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img3.jpg?raw=true)
```    
beeline
```	

3. Connect to the Spark Thrift Server via JDBC driver by entering the following string and providing account credentials for the admin. [Img. 4](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img4.jpg?raw=true)
```
!connect 'jdbc:hive2://<clustername>.azurehdinsight.net:443/default;ssl=true;transportMode=http;httpPath=/sparkhive2'
```	

HDInsight comes pre-loaded with a sample table called "hivesampletable" sitting on WASB storage.

4. List tables. [Img. 5](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img5.jpg?raw=true)
```
show tables;
```	

5. Let's check the time it will take to count number of all rows in the table while it is uncached for the reference. [Img. 6](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img6.jpg?raw=true)
```
select count(*) from hivesampletable;
```
Operation accomplished in **16 seconds**.

6. Cache the sample table in memory and then execute a one row count. You need to do this to commit the change as by default Spark performs "lazy execution". [Img. 7](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img7.jpg?raw=true)	
```
cache table hivesampletable;
select count(1) from hivesampletable;	
```	

7. Now let's compare the same row count with in-memory cached table. [Img. 8](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img8.jpg?raw=true)
```
select count(*) from hivesampletable;
```	

Not bad: under **0.5 second**! You can disconnect beeline client by executing
```
!q
```
8. Launch Power BI desktop and select **Get Data** -> **More**. [Img. 9](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img9.jpg?raw=true)

9. Select **Azure** and **Azure HDInsight Spark (Beta)**. [Img. 10](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img10.jpg?raw=true)

10. Specify the Spark cluster URL as **<sparkname>.azurehdinsight.net**. I picked **DirectQuery** as it allows to leverage the underlying Spark cluster processing power and not bringing all data into Power BI model. You can read more about Direct Query [here](https://powerbi.microsoft.com/en-us/documentation/powerbi-desktop-use-directquery/). [Img. 11](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img11.jpg?raw=true)

11. Let's provide the same admin credentials we used for connecting to the head node above. [Img. 12](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img12.jpg?raw=true)

12. Once connected you should be able to see the cluster and hivesampletable. [Img. 13](https://github.com/skepticatgit/tutorials/blob/master/sparktblcache/images/Img13.jpg?raw=true)

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
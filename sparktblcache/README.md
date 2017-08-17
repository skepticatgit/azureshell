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
- Provision HDInsight Spark cluster
- Connect to Thrift Server via beeline client
- Cache table in memory
- Connect PowerBI to Spark cached table 

##Before you begin

1. Azure HDInsight Spark cluster. Follow this [link](https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-apache-spark-jupyter-spark-sql) to create HDInsight Spark cluster.
2. Linux shell or command line interface. I am using Ubuntu Bash on Windows.
3. Desktop BI tool like Tableau or [Power BI desktop](https://powerbi.microsoft.com/en-us/downloads/).

##Step by step guide

Open the shell window and SSH to the HDInsight head node
`$ ssh <sshusername>@<clustername>-ssh.azurehdinsight.net`

![SSH log-in](/../images/Img1.jpg?raw=true "SSH log-in")

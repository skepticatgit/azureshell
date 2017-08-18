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
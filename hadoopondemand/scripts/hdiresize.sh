#!/bin/bash
# A simple Azure CLI

printf “Setting up the variables... \n”
export sp=<SERVICE_PRINCIPAL_ID> # you created this in the previous step
export sppass=< SERVICE_PRINCIPAL_PW> # you created this in the previous step
export rg=<RESOURCE_GROUP_NAME> # you created this in the previous step
export sparkname=<SPARK_NAME>

# Logging in with the Service Principal…
azure login --service-principal -u $sp -p $sppass --tenant Microsoft.com #your tenant is different

printf "Resizing HDI cluster... \n "
azure hdinsight cluster resize $sparkname 1 --resource-group $rg & #change 1 to desired number of nodes

printf "Logging out the Service Principal...\n "
azure logout $sp

printf "Done. Goodbye...\n "
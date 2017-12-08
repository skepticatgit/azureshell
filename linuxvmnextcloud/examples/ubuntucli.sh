#!/usr/bin/env bash
myResourceGroup=<setItHere>
myPublicDNS=<setItHere>
dnsSuffix=".cloudapp.azure.com"
myUser=<setItHere>
myPass=<setItHere>
vmSize=Standard_D1_v2

echo "STEP 1 of 8: Creating the resource group, please wait."
az group create --name $myResourceGroup --location eastus2

echo "STEP 2 of 8: Creating virtual network, please wait."
az network vnet create \
    --resource-group $myResourceGroup \
    --name myVnet \
    --address-prefix 192.168.0.0/16 \
    --subnet-name mySubnet \
    --subnet-prefix 192.168.1.0/24

echo "STEP 3 of 8: Creating Public IP, please wait."
az network public-ip create \
    --resource-group $myResourceGroup \
    --name myPublicIP \
    --dns-name $myPublicDNS

echo "STEP 4 of 8: Creating Network Security Group, please wait."
az network nsg create \
    --resource-group $myResourceGroup \
    --name myNetworkSecurityGroup

echo "STEP 5 of 8: Creating inbound firewall rule, please wait."
az network nsg rule create \
    --resource-group $myResourceGroup \
    --nsg-name myNetworkSecurityGroup \
    --name myNetworkSecurityGroupRuleSSH \
    --protocol tcp \
    --priority 1000 \
    --destination-port-range 22 \
    --access allow

echo "STEP 6 of 8: Creating inbound firewall rule, please wait."
az network nsg rule create \
    --resource-group $myResourceGroup \
    --nsg-name myNetworkSecurityGroup \
    --name myNetworkSecurityGroupRuleWeb \
    --protocol tcp \
    --priority 1001 \
    --destination-port-range 443 \
    --access allow

echo "STEP 7 of 8: Creating network interface card, please wait."
az network nic create \
    --resource-group $myResourceGroup \
    --name myNic \
    --vnet-name myVnet \
    --subnet mySubnet \
    --public-ip-address myPublicIP \
    --network-security-group myNetworkSecurityGroup

echo "STEP 8 of 8: Creating virtual machine, please wait."
az vm create \
    --resource-group $myResourceGroup \
    --name myVM \
    --location eastus2 \
    --nics myNic \
    --image UbuntuLTS \
    --authentication-type password \
    --admin-username $myUser \
    --admin-password $myPass \
    --size $vmSize

echo "Your VM has been successfully set-up. You can SSH to it via DNS name below:"
echo $myPublicDNS$dnsSuffix
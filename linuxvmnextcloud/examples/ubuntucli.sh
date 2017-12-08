#!/usr/bin/env bash
myResourceGroup=<setItHere>
myPublicDNS=<setItHere>
myUser=<setItHere>
myPass=<setItHere>
vmSize=Standard_D1_v2

az group create --name $myResourceGroup --location eastus2

az network vnet create \
    --resource-group $myResourceGroup \
    --name myVnet \
    --address-prefix 192.168.0.0/16 \
    --subnet-name mySubnet \
    --subnet-prefix 192.168.1.0/24

az network public-ip create \
    --resource-group $myResourceGroup \
    --name myPublicIP \
    --dns-name $myPublicDNS

az network nsg create \
    --resource-group $myResourceGroup \
    --name myNetworkSecurityGroup

az network nsg rule create \
    --resource-group $myResourceGroup \
    --nsg-name myNetworkSecurityGroup \
    --name myNetworkSecurityGroupRuleSSH \
    --protocol tcp \
    --priority 1000 \
    --destination-port-range 22 \
    --access allow

az network nsg rule create \
    --resource-group $myResourceGroup \
    --nsg-name myNetworkSecurityGroup \
    --name myNetworkSecurityGroupRuleWeb \
    --protocol tcp \
    --priority 1001 \
    --destination-port-range 443 \
    --access allow

az network nic create \
    --resource-group $myResourceGroup \
    --name myNic \
    --vnet-name myVnet \
    --subnet mySubnet \
    --public-ip-address myPublicIP \
    --network-security-group myNetworkSecurityGroup

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
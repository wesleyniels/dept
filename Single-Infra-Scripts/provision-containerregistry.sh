#! /bin/bash

#please login
#az login
az account set --subscription "xxxxx-xxxx-xxxxx-xxx-xxxxxxx"

#set your vars
Region="westeurope"
Environment="staging"
CustomerAbbr="ter"

registryName="${CustomerAbbr}contreg${Environment}"
registrySku="Standard"
adminUserEnabled="true"
location="westeurope"
CreateContainerRegistry="true"
RSGName="$CustomerAbbr-rsg-$Environment"

#Generate variables based on naming convention
echo "creating resourcegroup $RSGName"
az group create -l $Region -n $RSGName

# deploy, specifying all template parameters directly
templateUri="armdeployContainerRegistry.json"
az group deployment create \
    --name $Environment \
    --resource-group $RSGName \
    --template-file $templateUri \
    --parameters "registryName=$registryName" \
                 "registrySku=$registrySku" \
                 "registryLocation=$location" \
                 "adminUserEnabled=$adminUserEnabled"

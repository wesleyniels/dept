#! /bin/bash

registryName="${CustomerAbbr}contreg${Environment}"
registrySku="Standard"
adminUserEnabled="true"
location="westeurope"
CreateContainerRegistry="true"

#Generate variables based on naming convention
RSGName="$CustomerAbbr-rsg-$Environment"

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

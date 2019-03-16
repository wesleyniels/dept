#! /bin/bash

#please login
#az login
az account set --subscription "xxxx-xxxxx-xxxx-xxxxxx"

#set your vars
Region="westeurope"
Environment="staging"
CustomerAbbr="ter"

#Generate variables based on naming convention
RSGName="$CustomerAbbr-rsg-$Environment"
WebAppName="$CustomerAbbr-web-$Environment"
AppServicePlan="$CustomerAbbr-sp-$Environment"

#Create resourcegroup
echo "creating resourcegroup $RSGName"
az group create -l $Region -n $RSGName

StorageAccountName="${CustomerAbbr}stor${Environment}"
AccountType="Standard_RAGRS"
Kind="StorageV2"
AccessTier="Hot"
HttpsOnly="true"

#Generate variables based on naming convention
RSGName="$CustomerAbbr-rsg-$Environment"

templateUri="armdeploystorage.json"
az group deployment create \
    --name $Environment \
    --resource-group $RSGName \
    --template-file $templateUri \
    --parameters "location=$Region" \
                 "storageAccountName=$StorageAccountName" \
                 "accountType=$AccountType" \
                 "kind=$Kind" \
                 "accessTier=$AccessTier" \
                 "supportsHttpsTrafficOnly=$HttpsOnly"

#Create BOB for mediafiles usage
az storage container create --name "${CustomerAbbr}blob${Environment}" --public-access blob --account-name "${CustomerAbbr}stor${Environment}"

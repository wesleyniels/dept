#! /bin/bash

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

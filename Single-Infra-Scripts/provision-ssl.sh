#! /bin/bash

#please login
#az login
az account set --subscription "xxxxx-xxxx-xxxxx-xxxx"

#set your vars
Region="westeurope"
Environment="staging"
CustomerAbbr="ter"

hostingPlanName="$CustomerAbbr-sp-$Environment"
location="westeurope"
subscriptionId="xxxxx-xxxx-xxxxx-xxx-xxxxxxx"
keyvaultname="$CustomerAbbr-key-$Environment"
AddSSL="true"
fqdn="api-$Environment.website.nl"

#Generate variables based on naming convention
RSGName="$CustomerAbbr-rsg-$Environment"
WebAppName="$CustomerAbbr-api-$Environment"
AppServicePlan="$CustomerAbbr-sp-$Environment"

#Create resourcegroup
echo "creating resourcegroup $RSGName"
az group create -l $Region -n $RSGName

templateUri="armdeployssl.json"
az group deployment create \
    --name $Environment \
    --resource-group $RSGName \
    --template-file $templateUri \
    --parameters "existingServerFarmId=/subscriptions/$subscriptionId/resourceGroups/$RSGName/providers/Microsoft.Web/serverfarms/$AppServicePlan" \
                 "certificateName=certificatename" \
                 "existingKeyVaultId=/subscriptions/$subscriptionId/resourceGroups/$RSGName/providers/Microsoft.KeyVault/vaults/$keyvaultname" \
                 "existingKeyVaultSecretName=certificatename" \
                 "existingWebAppName=$WebAppName" \
                 "hostname=$fqdn" \
                 "existingAppLocation=$location" \
                 "location=$location"

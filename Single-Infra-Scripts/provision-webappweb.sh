#! /bin/bash

#please login
#az login
az account set --subscription "xxxx-xxxxx-xxxx-xxxxx"

#set your vars
Region="westeurope"
Environment="staging"
CustomerAbbr="ter"

registryName="${CustomerAbbr}contreg${Environment}"
dockerRegistryUrl="https://${CustomerAbbr}contreg${Environment}.azurecr.io"
dockerRegistryUsername="${CustomerAbbr}contreg${Environment}"
dockerRegistryPassword=$(az acr credential show --name $registryName --query "passwords[0].value")
wordpressDBhost="$CustomerAbbr-mysql-$Environment"
wordpressDBname="webdb"
keyvaultName="$CustomerAbbr-key-$Environment"
keyVaultWPDBID=$(az keyvault secret show --vault-name $keyvaultName --name WORDPRESSDBPASSWORD --query id -o tsv)
wordpressDBpassword="@Microsoft.KeyVault(SecretUri=$keyVaultWPDBID)"
wordpressDBuser="${CustomerAbbr}mysqladmin@$CustomerAbbr-mysql-$Environment"
location="West Europe"
subscriptionId="xxxxx-xxxx-xxxxx-xxx-xxxxxxx"
sku="PremiumV2"
skuCode="P1v2"
workerSize="3"
fqdn="${Environment}.website.nl"

#Generate variables based on naming convention
RSGName="$CustomerAbbr-rsg-$Environment"
SQLServerName="$CustomerAbbr-mysql-$Environment"
WebAppName="$CustomerAbbr-web-$Environment"
AppServicePlan="$CustomerAbbr-sp-$Environment"
hostingEnvironment=""

#Create resourcegroup
echo "creating resourcegroup $RSGName"
az group create -l $Region -n $RSGName

templateUri="armdeployWebAppforContainers-web.json"
az group deployment create \
    --name $Environment \
    --resource-group $RSGName \
    --template-file $templateUri \
    --parameters "name=$WebAppName" \
                 "hostingPlanName=$AppServicePlan" \
                 "location=$location" \
                 "serverFarmResourceGroup=$RSGName" \
                 "dockerRegistryUrl=$dockerRegistryUrl" \
                 "dockerRegistryUsername=$dockerRegistryUsername" \
                 "dockerRegistryPassword=$dockerRegistryPassword" \
                 "hostingEnvironment=$hostingEnvironment" \
                 "subscriptionId=$subscriptionId" \
                 "sku=$sku" \
                 "skuCode=$skuCode" \
                 "workerSize=$workerSize"

echo "Applying application settings"
az webapp config appsettings set -g $RSGName -n $WebAppName --settings WORDPRESS_DB_HOST=$wordpressDBhost.mysql.database.azure.com
az webapp config appsettings set -g $RSGName -n $WebAppName --settings WORDPRESS_DB_NAME=${wordpressDBname}
az webapp config appsettings set -g $RSGName -n $WebAppName --settings WORDPRESS_DB_PASSWORD=${wordpressDBpassword}
az webapp config appsettings set -g $RSGName -n $WebAppName --settings WORDPRESS_DB_USER=${wordpressDBuser}

#Continous Deployment is set to ON
az webapp config appsettings set -g $RSGName -n $WebAppName --settings DOCKER_ENABLE_CI=true

#Set WebApp to AlwaysOn
az webapp config set -g $RSGName -n $WebAppName --always-on true

#Configure System Assigned Identity
az webapp identity assign -g $RSGName -n "${CustomerAbbr}-web-${Environment}"

#Add hostname and SSL certificate
az webapp config hostname add --webapp-name $WebAppName --resource-group $RSGName --hostname $fqdn
WebAppID=$(az webapp identity show --resource-group $RSGName --name "${CustomerAbbr}-web-${Environment}" --query principalId -o tsv)
az keyvault set-policy --name $keyvaultName --object-id $WebAppID --secret-permissions Get --certificate-permissions Get

#Add static principal Microsoft Azure App Service
az keyvault set-policy --name $keyvaultName --spn abfa0a7c-a6b6-4736-8310-5855508787cd --secret-permissions Get

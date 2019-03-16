#! /bin/bash

#please login
#az login
az account set --subscription "xxxx-xxxx-xxxx-xxxx"

#set your vars
Region="westeurope"
Environment="staging"
CustomerAbbr="ter"

registryName="${CustomerAbbr}contreg${Environment}"
dockerRegistryUrl="https://${CustomerAbbr}contreg${Environment}.azurecr.io"
dockerRegistryUsername="${CustomerAbbr}contreg${Environment}"
dockerRegistryPassword=$(az acr credential show --name $registryName --query "passwords[0].value")
location="West Europe"
subscriptionId="xxxxx-xxxx-xxxxx-xxx-xxxxxxx"
CreateWebApp="true"
sku="PremiumV2"
skuCode="P1v2"
workerSize="3"
keyvaultName="$CustomerAbbr-key-$Environment"
keyVaultPSDBPWID=$(az keyvault secret show --vault-name $keyvaultName --name POSTGRESDBPASSWORD --query id -o tsv)

postgresconnectiontype="postgres"
postgresdatabase="nodejs-api"
postgreshost="$CustomerAbbr-sql-$Environment.POSTGRES.database.azure.com"
Ppostgreslogging="false"
postgrespassword="@Microsoft.KeyVault(SecretUri=$keyVaultidPSDBPWID)"
postgresport="5432"
postgressynchronize="false"
postgresusername="${CustomerAbbr}sqladmin@$CustomerAbbr-sql-$Environment"
websitesport="3000"

fqdn="api-$Environment.website.nl"

#Generate variables based on naming convention
RSGName="$CustomerAbbr-rsg-$Environment"
SQLServerName="$CustomerAbbr-mysql-$Environment"
WebAppName="$CustomerAbbr-api-$Environment"
AppServicePlan="$CustomerAbbr-sp-$Environment"
hostingEnvironment=""

#Create resourcegroup
echo "creating resourcegroup $RSGName"
az group create -l $Region -n $RSGName

templateUri="armdeployWebAppforContainers-api.json"
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
az webapp config appsettings set -g $RSGName -n $WebAppName --settings POSTGRES_CONNECTION=${postgresconnectiontype}
az webapp config appsettings set -g $RSGName -n $WebAppName --settings POSTGRES_DATABASE=${postgresdatabase}
az webapp config appsettings set -g $RSGName -n $WebAppName --settings POSTGRES_HOST=${postgreshost}
az webapp config appsettings set -g $RSGName -n $WebAppName --settings POSTGRES_LOGGING=${postgreslogging}
az webapp config appsettings set -g $RSGName -n $WebAppName --settings POSTGRES_PASSWORD=${postgrespassword}
az webapp config appsettings set -g $RSGName -n $WebAppName --settings POSTGRES_PORT=${postgresport}
az webapp config appsettings set -g $RSGName -n $WebAppName --settings POSTGRES_SYNCHRONIZE=${postgressynchronize}
az webapp config appsettings set -g $RSGName -n $WebAppName --settings POSTGRES_USERNAME=${postgresusername}

#Website runs on port 3000
az webapp config appsettings set -g $RSGName -n $WebAppName --settings WEBSITES_PORT=${websitesport}

#Continous Deployment is set to ON
az webapp config appsettings set -g $RSGName -n $WebAppName --settings DOCKER_ENABLE_CI=true

#Configure System Assigned Identity
az webapp identity assign -g $RSGName -n "${CustomerAbbr}-api-${Environment}"

#Set WebApp to AlwaysOn
az webapp config set -g $RSGName -n $WebAppName --always-on true

#Add hostname and SSL certificate
az webapp config hostname add --webapp-name $WebAppName --resource-group $RSGName --hostname $fqdn
thumbprint=$(az keyvault certificate show --name sslcertificatename --vault-name $keyvaultName --query x509ThumbprintHex --output tsv)
az webapp config ssl bind --certificate-thumbprint $thumbprint --ssl-type SNI --name $WebAppName --resource-group $RSGName

#! /bin/bash

registryName="${CustomerAbbr}contreg${Environment}"
dockerRegistryUrl="https://${CustomerAbbr}contreg${Environment}.azurecr.io"
dockerRegistryUsername="${CustomerAbbr}contreg${Environment}"
dockerRegistryPassword=$(az acr credential show --name $registryName --query "passwords[0].value")
hostingPlanName="$CustomerAbbr-sp-$Environment"
location="West Europe"
subscriptionId="xxxxx-xxxx-xxxxx-xxx-xxxxxxx"
hostingEnvironment=""
CreateWebApp="true"
sku="PremiumV2"
skuCode="P1v2"
workerSize="3"
fqdn="essie-${Environment}.website.nl"
keyvaultName="$CustomerAbbr-key-$Environment"
websitesport="5000"

#Generate variables based on naming convention
RSGName="$CustomerAbbr-rsg-$Environment"
SQLServerName="$CustomerAbbr-mysql-$Environment"
WebAppName="$CustomerAbbr-essie-$Environment"
AppServicePlan="$CustomerAbbr-sp-$Environment"


templateUri="armdeployWebAppforContainers-essie.json"
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

#Website runs on port 3000
az webapp config appsettings set -g $RSGName -n $WebAppName --settings WEBSITES_PORT=${websitesport}

#Continous Deployment is set to ON
az webapp config appsettings set -g $RSGName -n $WebAppName --settings DOCKER_ENABLE_CI=true

#Set WebApp to AlwaysOn
az webapp config set -g $RSGName -n $WebAppName --always-on true

#Add hostname and SSL certificate
az webapp config hostname add --webapp-name $WebAppName --resource-group $RSGName --hostname $fqdn
thumbprint=$(az keyvault certificate show --name sslcertificatename --vault-name $keyvaultName --query x509ThumbprintHex --output tsv)
az webapp config ssl bind --certificate-thumbprint $thumbprint --ssl-type SNI --name $WebAppName --resource-group $RSGName

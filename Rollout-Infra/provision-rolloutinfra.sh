#! /bin/bash

#please login
#az login
az account set --subscription "xxxxx-xxxx-xxxxx-xxx-xxxxxxx"
export $(cat customer-variables.env | grep -v ^# | xargs)

CreateWebAppEssie="true"
CreateWebAppApi="true"
CreateWebAppWeb="true"
CreateSendgrid="true"
CreateMySQL="true"
CreatePostgres="true"
CreateContainerRegistry="true"
CreateStorage="true"
CreateKeyvault="true"
DeployDockerImage="true"
DeploySSL="true"

#Generate variables based on naming convention
echo "Generating variables"
RSGName="$CustomerAbbr-rsg-$Environment"

#Create resourcegroup
tput setaf 5; echo "Creating Resource Group $RSGName"
az group create -l $Region -n $RSGName &> /dev/null
tput setaf 2; echo "Resource Group succesfully created"
tput sgr0

if [ "$CreateContainerRegistry" == true ];
then
tput setaf 5; echo "Deploying Container Registry"
sh provision-containerregistry-infra.sh &> /dev/null
tput setaf 2; echo "Deployed Succesfully Container Registry"
tput sgr0

else
tput setaf 1; echo "Not Deploying Container Registry"
tput sgr0
fi

#Pull docker image and upload to registry
if [ "$DeployDockerImage" == true ];
then
tput setaf 5; echo "Deploying Docker Image and push to Registry"
sh provision-dockerimage-infra.sh &> /dev/null
tput setaf 2; echo "Succesfully Deployed Docker Image"
tput sgr0

else
tput setaf 1; echo "Not Deploying Docker Image"
tput sgr0
fi

#Create Keyvault and add certificates and secrets
if [ "$CreateKeyvault" == true ];
then
tput setaf 5; echo "Deploying Keyvault"
sh provision-keyvault-infra.sh
tput setaf 2; echo "Succesfully Deployed Keyvault"
tput sgr0

else
tput setaf 1; echo "Not Deploying Keyvault"
tput sgr0
fi

#Create Sengrid Subscription
if [ "$CreateSendgrid" == true ];
then
tput setaf 5; echo "Deploying Sendgrid"
sh provision-sendgrid-infra.sh
tput setaf 2; echo "Succesfully Deployed Sendgrid"
tput sgr0

else
tput setaf 1; echo "Not Deploying Sendgrid"
tput sgr0
fi

#Create WebApp
if [ "$CreateWebAppWeb" == true ];
then
tput setaf 5; echo "Deploying WebAppWeb"
sh provision-webappweb-infra.sh &> /dev/null
tput setaf 2; echo "Succesfully Deployed WebAppWeb"
tput sgr0

else
tput setaf 1; echo "Not Deploying the WebAppWeb"
tput sgr0
fi

#Add SSL certificate to Keyvault
if [ "$DeploySSL" == true ];
then
tput setaf 5; echo "Deploying SSL"
sh provision-ssl-infra.sh &> /dev/null
tput setaf 2; echo "Succesfully Deployed SSL"
tput sgr0

else
tput setaf 1; echo "Not Deploying SSL"
tput sgr0
fi

if [ "$CreateWebAppApi" == true ];
then
tput setaf 5; echo "Deploying WebAppApi"
sh provision-webappapi-infra.sh &> /dev/null
tput setaf 2; echo "Succesfully Deployed WebAppApi"
tput sgr0

else
tput setaf 1; echo "Not Deploying WebAppApi"
tput sgr0
fi

if [ "$CreateWebAppEssie" == true ];
then
tput setaf 5; echo "Deploying WebAppEssie"
sh provision-webappessie-infra.sh &> /dev/null
tput setaf 2; echo "Succesfully Deployed WebAppEssie"
tput sgr0

else
tput setaf 1; echo "Not Deploying WebAppEssie"
tput sgr0
fi

if [ "$CreatePostgres" == true ];
then
tput setaf 5; echo "Deploying Postgres"
sh provision-postgres-infra.sh &> /dev/null
tput setaf 2; echo "Succesfully Deployed Postgres"
tput sgr0

else
tput setaf 1; echo "Not Deploying Postgres"
tput sgr0
fi

if [ "$CreateMySQL" == true ];
then
tput setaf 5; echo "Deploying MySQL"
sh provision-mysql-infra.sh &> /dev/null
tput setaf 2; echo "Succesfully Deployed MySQL"
tput sgr0

else
tput setaf 1; echo "Not Deploying MySql"
tput sgr0
fi

if [ "$CreateStorage" == true ];
then
tput setaf 5; echo "Deploying Storage"
sh provision-storage-infra.sh &> /dev/null
tput setaf 2; echo "Succesfully Deployed Storage"
tput sgr0

else
tput setaf 1; echo "Not Deploying Storage"
tput sgr0
fi

tput setaf 2; echo "Done provisioning Azure Infrastructure"
tput sgr0

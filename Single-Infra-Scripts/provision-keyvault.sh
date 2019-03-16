#! /bin/bash

#please login
#az login
az account set --subscription "xxxx-xxxx-xxxx-xxxxxx"

#set your vars
Region="westeurope"
Environment="staging"
CustomerAbbr="ter"

subscriptionId="xxxxx-xxxx-xxxxx-xxx-xxxxxxx"
RSGName="$CustomerAbbr-rsg-$Environment"
keyVaultName="$CustomerAbbr-key-$Environment"
location='westeurope'
#define user which has deployment permissions
userPrincipalName='user@domain.com'

#Create resourcegroup
RSGName="$CustomerAbbr-rsg-$Environment"
echo "creating resourcegroup $RSGName"
az group create -l $Region -n $RSGName

# deploy, specifying all template parameters directly
az keyvault create \
  --name $keyVaultName \
  --resource-group $RSGName \
  --location $location \
  --enabled-for-template-deployment true &> /dev/null

# add UPN to Keyvault for uploading certificates & secrets
az keyvault set-policy --upn $userPrincipalName --name $keyVaultName --secret-permissions set delete get list &> /dev/null

# Insert keys manually and add them as secret
echo Please enter ZoneAtlas Password:
read passwordzone
az keyvault secret set --vault-name $keyVaultName --name 'APPLICATIONPASSWORD' --value $passwordzone &> /dev/null

echo Please enter PFX Password:
read pfxPassword
az keyvault certificate import --vault-name $keyVaultName --name sslcertificatename --file certificatename.pfx --password $pfxPassword &> /dev/null

# Automatically generate passwords and add them as secret
passwordpgdb=$(openssl rand -base64 32)
az keyvault secret set --vault-name $keyVaultName --name 'POSTGRESDBPASSWORD' --value $passwordpgdb &> /dev/null

passwordwpdb=$(openssl rand -base64 32)
az keyvault secret set --vault-name $keyVaultName --name 'WORDPRESSDBPASSWORD' --value $passwordwpdb &> /dev/null

passwordsgpw=$(openssl rand -base64 32)
az keyvault secret set --vault-name $keyVaultName --name 'SENDGRIDPW' --value $passwordsgpw &> /dev/null
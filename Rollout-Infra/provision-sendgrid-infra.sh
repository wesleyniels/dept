#! /bin/bash

location="westeurope"
plan_name="free"
plan_publisher="Sendgrid"
plan_product="sendgrid_azure"
plan_promotion_code=""
keyVaultName="$CustomerAbbr-key-$Environment"
keyVaultsecret="SENDGRIDPW"
password=$(az keyvault secret show --vault-name $keyVaultName --name $keyVaultsecret --query value -o tsv)
email="ops@nl.deptagency.com"
firstName="Dept"
lastName="DevOps"
company="CompanyName"
website="www.websitename.nl"
acceptMarketingEmails="0"

#Generate variables based on naming convention
RSGName="$CustomerAbbr-rsg-$Environment"
name="${CustomerAbbr}sendgrid${Environment}"

# deploy, specifying all template parameters directly
templateUri="armdeploysendgrid.json"
az group deployment create \
    --name $Environment \
    --resource-group $RSGName \
    --template-file $templateUri \
    --parameters "name=$name" \
                 "location=$location" \
                 "plan_name=$plan_name" \
                 "plan_publisher=$plan_publisher" \
                 "plan_product=$plan_product" \
                 "plan_promotion_code=$plan_promotion_code" \
                 "password=$password" \
                 "email=$email" \
                 "firstName=$firstName" \
                 "lastName=$lastName" \
                 "company=$company" \
                 "website=$website" \
                 "acceptMarketingEmails=$acceptMarketingEmails"  &> /dev/null

# Retrieve API key and enter to Keyvault
echo Please enter Sengrid API Key to add to Keyvault:
read passwordsgapi
az keyvault secret set --vault-name $keyVaultName --name 'SENDGRIDAPIKEY' --value $passwordsgapi &> /dev/null

#! /bin/bash

keyVaultName="$CustomerAbbr-key-$Environment"
SQLPass=$(az keyvault secret show --vault-name $keyVaultName --name WORDPRESSDBPASSWORD --query value -o tsv)
SQLAdmin="${CustomerAbbr}mysqladmin"
SKU="S1"
location="westeurope"
skuName="GP_Gen5_2"
skuTier="GeneralPurpose"
skuCapacity="2"
skuFamily="Gen5"
skuSizeMB="102400"
version="5.7"
backupRetentionDays="7"
geoRedundantBackup="Disabled"

#Generate variables based on naming convention
RSGName="$CustomerAbbr-rsg-$Environment"
SQLServerName="$CustomerAbbr-mysql-$Environment"
WebAppName="$CustomerAbbr-web-$Environment"
AppServicePlan="$CustomerAbbr-sp-$Environment"

# deploy, specifying all template parameters directly

templateUri="armdeploymysql.json"
az group deployment create \
    --name $Environment \
    --resource-group $RSGName \
    --template-file $templateUri \
    --parameters "version=$version" \
                 "location=$location" \
                 "administratorLogin=$SQLAdmin" \
                 "administratorLoginPassword=$SQLPass" \
                 "serverName=$SQLServerName" \
                 "skuSizeMB=$skuSizeMB" \
                 "skuName=$skuName" \
                 "skuTier=$skuTier" \
                 "skuFamily=$skuFamily" \
                 "skuCapacity=$skuCapacity" \
                 "backupRetentionDays=$backupRetentionDays" \
                 "geoRedundantBackup=$geoRedundantBackup"

az mysql server update --resource-group $RSGName --name $SQLServerName --ssl-enforcement Disabled
#AllowAccessAzure firewall rule gives Azure Resources permission to connect to databases
az mysql server firewall-rule create --resource-group $RSGName --server $SQLServerName --name AllowAccessAzure --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
az mysql server firewall-rule create --resource-group $RSGName --server $SQLServerName --name DeptAmsterdam --start-ip-address 89.20.163.66 --end-ip-address 89.20.163.66
az mysql server firewall-rule create --resource-group $RSGName --server $SQLServerName --name DeptRdam --start-ip-address 89.20.163.70 --end-ip-address 89.20.163.70
az mysql server firewall-rule create --resource-group $RSGName --server $SQLServerName --name DeptVPN --start-ip-address 213.214.122.237 --end-ip-address 213.214.122.237

#This part will retrieve the outbound ip's of WebApps and add them to the firewall
OIFS=$IFS;
IFS=",";
outboundips=$(az webapp show -n $WebAppName -g $RSGName --query outboundIpAddresses)
outboundips=${outboundips%\"}
outboundips=${outboundips#\"}
outboundipsArray=($outboundips);

webappcounter=1;
for i in ${outboundipsArray[@]}
do
az mysql server firewall-rule create --resource-group $RSGName --server $SQLServerName --name $WebAppName$webappcounter --start-ip-address $i --end-ip-address $i;
webappcounter=$(($webappcounter+1));
done
IFS=$OIFS;

#! /bin/bash

#please login
#az login
az account set --subscription "xxxxx-xxxx-xxxxx-xxx-xxxxxxx"

#set your vars
Region="westeurope"
RSGName="cust-rsg-acc"

#cleanup
az group delete -n $RSGName

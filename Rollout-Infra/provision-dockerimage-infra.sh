#! /bin/bash

registryName="${CustomerAbbr}contreg${Environment}"
registrySku="Standard"
adminUserEnabled="true"
location="westeurope"
CreateContainerRegistry="true"


# pull docker image as example and tag it with a specific name
docker pull hello-world
docker tag hello-world "$registryName.azurecr.io/website"
docker rmi hello-world

# Login to registry and push container
az acr login --name $registryName
registryPass=$(az acr credential show --name $registryName --query "passwords[0].value")
docker login "$registryName.azurecr.io" -u $registryName -p $registryPass
docker push "$registryName.azurecr.io/website"

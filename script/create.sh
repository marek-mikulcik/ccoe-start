#!/bin/bash
echo "Please read rerequirements"

#Prereq
#az extension add --name azure-devops
#az devops configure --defaults organization=https://dev.azure.com/organization/
#az login

sId=$1
devopsProjectName=$2
az account set -s $sId
sName=$(az account list --query "[?id=='$sId'].name" -o tsv)
echo "Subscription name is '$sName'"
spName=$(echo "$sName-tfsp" | tr [:upper:] [:lower:] | tr ' ' '-')
echo "Service principal name will be '$spName'"
tfspOId=$(az ad sp list --spn http://$spName --query [].objectId -o tsv)
if [ ${#tfspOId} -ne 0 ]
then 
  echo "Deleting old sp"
  az ad sp delete --id $tfspOId
fi
spResult=$(az ad sp create-for-rbac -n $spName --create-cert --role contributor --scopes /subscriptions/$sId --years 5)
appId=$(echo $spResult | jq .appId | tr -d '"')
tenantId=$(echo $spResult | jq .tenant | tr -d '"')
filePath=$(echo $spResult | jq .fileWithCertAndPrivateKey | tr -d '"')
serviceName="Terraform $sName"
echo "Creating DevOps service connection"
az devops service-endpoint azurerm create --azure-rm-service-principal-id $appId --azure-rm-subscription-id $sId --azure-rm-subscription-name "$sName" --azure-rm-tenant-id $tenantId --name "$serviceName" --azure-rm-service-principal-certificate-path $filePath --org "https://dev.azure.com/swissre/"  --project "$devopsProjectName"
tfspOId=$(az ad sp list --spn http://$spName --query [].objectId -o tsv)
echo "Creating Terraform infrastructure"
stgName=$(echo "$sName tfstg" | tr [:upper:] [:lower:] | tr -d ' ')
rsgName=$(echo "$sName-ccoe-tf-rg" | tr [:upper:] [:lower:] | tr ' ' '-')
kvName=$(echo "$sName-ccoe-tf-kv" | tr [:upper:] [:lower:] | tr ' ' '-')
echo "Creating Terraform infrastructure in resource group $rsgName"
az group create -l westeurope -n $rsgName
az storage account create -n $stgName -g $rsgName -l westeurope --sku Standard_LRS --kind StorageV2
az storage container create -n tfstate --account-name $stgName
az keyvault create --name $kvName --resource-group $rsgName
az keyvault certificate import --vault-name $kvName --name tfsp-pem-certificate --file $filePath
az keyvault set-policy --name $kvName --object-id $tfspOId --secret-permissions get --key-permissions get --certificate-permissions get

tfspAppId=$(az ad sp list --spn http://$spName --query [].appId -o tsv)
echo "Use $tfspAppId as clientId"
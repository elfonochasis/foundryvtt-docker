# Change these parameters as needed
FOUNDRY_USERNAME='<<FoundryUsername>>'
FOUNDRY_PASSWORD='<<FoundryPassword>>'
FOUNDRY_ADMIN_KEY=admin123
ACI_CPU_COUNT=2
ACI_MEM_GB=4
ACI_NAME='<<UniqueAzureContainerInstanceName>>'
ACI_PERS_RESOURCE_GROUP='FoundryVTT'
ACI_PERS_STORAGE_ACCOUNT_NAME='<<UniqueStorageAccountName>>'
ACI_PERS_LOCATION=eastus
ACI_PERS_SHARE_NAME=vttdata

# Create the resource group
az group create --name $ACI_PERS_RESOURCE_GROUP --location $ACI_PERS_LOCATION
echo 'Resource Group Created'

# Create the storage account with the parameters
az storage account create \
    --resource-group $ACI_PERS_RESOURCE_GROUP \
    --name $ACI_PERS_STORAGE_ACCOUNT_NAME \
    --location $ACI_PERS_LOCATION \
    --sku Standard_LRS
echo 'Storage Account Created'

# Create the file share
az storage share create \
  --name $ACI_PERS_SHARE_NAME \
  --account-name $ACI_PERS_STORAGE_ACCOUNT_NAME
echo 'File Share Created'

STORAGE_KEY=$(az storage account keys list --resource-group $ACI_PERS_RESOURCE_GROUP --account-name $ACI_PERS_STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv)
echo 'Fetched the storage account key...'

az container create \
    --resource-group $ACI_PERS_RESOURCE_GROUP \
    --name $ACI_NAME \
    --cpu $ACI_CPU_COUNT \
    --memory $ACI_MEM_GB \
    --port 80 443\
    --image armyguy255a/foundryvtt:latest \
    --dns-name-label $ACI_NAME \
    --azure-file-volume-account-name $ACI_PERS_STORAGE_ACCOUNT_NAME \
    --azure-file-volume-account-key $STORAGE_KEY \
    --azure-file-volume-share-name $ACI_PERS_SHARE_NAME \
    --azure-file-volume-mount-path /data \
    --environment-variables CONTAINER_CACHE=/data/cache CONTAINER_PATCHES=/data/patches CONTAINER_PRESERVE_CONFIG=true \
    --secure-environment-variables FOUNDRY_USERNAME=$FOUNDRY_USERNAME FOUNDRY_PASSWORD=$FOUNDRY_PASSWORD FOUNDRY_ADMIN_KEY=$FOUNDRY_ADMIN_KEY
echo 'Azure Container Instance Created'
# Change these four parameters as needed
ACI_PERS_RESOURCE_GROUP='<<ResourceGroupToCreate>>'
ACI_PERS_STORAGE_ACCOUNT_NAME='<<StorageNameToCreate>>'
ACI_PERS_LOCATION=eastus
ACI_PERS_SHARE_NAME=vttdata
ACI_NAME='<<AzureContainerInstanceToCreate>>'

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
echo $STORAGE_KEY

az container create \
    --resource-group $ACI_PERS_RESOURCE_GROUP \
    --name $ACI_NAME \
    --image felddy/foundryvtt:release \
    --dns-name-label $ACI_NAME \
    --azure-file-volume-account-name $ACI_PERS_STORAGE_ACCOUNT_NAME \
    --azure-file-volume-account-key $STORAGE_KEY \
    --azure-file-volume-share-name $ACI_PERS_SHARE_NAME \
    --azure-file-volume-mount-path /data \
    --environment-variables CONTAINER_CACHE=/data/cache CONTAINER_PATCHES=/data/patches \
    --secure-environment-variables FOUNDRY_USERNAME=xxxx FOUNDRY_PASSWORD=xxxx FOUNDRY_ADMIN_KEY=admin123
echo 'Azure Container Instance Created'

# setup-azure-storage.sh
#!/bin/bash
# Script to create Azure Storage for Terraform state backend

# Variables - replace with your values
RESOURCE_GROUP_NAME="terraform-state-rg"
STORAGE_ACCOUNT_NAME="yourtfstatestorage"  # must be globally unique
CONTAINER_NAME="tfstate"
LOCATION="eastus"

# Create resource group
echo "Creating resource group $RESOURCE_GROUP_NAME..."
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
echo "Creating storage account $STORAGE_ACCOUNT_NAME..."
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --sku Standard_LRS \
  --encryption-services blob

# Get storage account key
echo "Retrieving storage account key..."
ACCOUNT_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --query [0].value -o tsv)

# Create blob container
echo "Creating blob container $CONTAINER_NAME..."
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME \
  --account-key $ACCOUNT_KEY

echo "Terraform state storage has been configured."
echo "Resource Group:  $RESOURCE_GROUP_NAME"
echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo "Container:       $CONTAINER_NAME"

# Create service principal for GitHub Actions
echo "Creating service principal for GitHub Actions..."
az ad sp create-for-rbac \
  --name "github-actions-sqlmi" \
  --role Contributor \
  --scopes /subscriptions/$(az account show --query id -o tsv) \
  --sdk-auth

echo "Copy the above JSON output and store it securely."
echo "Use these values for your GitHub secrets:"
echo "- AZURE_CLIENT_ID"
echo "- AZURE_CLIENT_SECRET"
echo "- AZURE_SUBSCRIPTION_ID"
echo "- AZURE_TENANT_ID"

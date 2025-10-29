#!/bin/bash
# Quick Azure Deployment Script (for Windows with Git Bash or WSL)

set -e

echo "🚀 Azure Deployment - React Chatbot"
echo "===================================="

# 1. Login
echo "📝 Logging in to Azure..."
az login

# 2. Get subscription
SUBSCRIPTION=$(az account show --query id -o tsv)
echo "✅ Using subscription: $SUBSCRIPTION"

# 3. Variables
RESOURCE_GROUP="react-chatbot-rg"
LOCATION="eastus"
ACR_NAME="reactchatbot${RANDOM}"
ACI_NAME="react-chatbot-aci"

echo ""
echo "🔧 Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Location: $LOCATION"
echo "  ACR Name: $ACR_NAME"
echo ""

# 4. Create resource group
echo "📁 Creating Resource Group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# 5. Create ACR
echo "🐳 Creating Container Registry..."
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

# 6. Build and push
echo "🔨 Building Docker image..."
az acr build \
  --resource-group $RESOURCE_GROUP \
  --registry $ACR_NAME \
  --image react-chatbot:latest \
  .

# 7. Get credentials
ACR_LOGIN_SERVER=$(az acr show --resource-group $RESOURCE_GROUP --name $ACR_NAME --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show --resource-group $RESOURCE_GROUP --name $ACR_NAME --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --resource-group $RESOURCE_GROUP --name $ACR_NAME --query passwords[0].value -o tsv)

# 8. Deploy to ACI
echo "☁️  Deploying to Container Instances..."
az container create \
  --resource-group $RESOURCE_GROUP \
  --name $ACI_NAME \
  --image "$ACR_LOGIN_SERVER/react-chatbot:latest" \
  --cpu 1 \
  --memory 1 \
  --registry-login-server $ACR_LOGIN_SERVER \
  --registry-username $ACR_USERNAME \
  --registry-password $ACR_PASSWORD \
  --ports 3000 \
  --dns-name-label "react-chatbot-${RANDOM}" \
  --restart-policy OnFailure

# 9. Get URL
ACI_FQDN=$(az container show \
  --resource-group $RESOURCE_GROUP \
  --name $ACI_NAME \
  --query ipAddress.fqdn -o tsv)

echo ""
echo "╔════════════════════════════════════════════════╗"
echo "║   ✅ DEPLOYMENT SUCCESSFUL!                   ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
echo "🌐 Your app is live at: http://$ACI_FQDN:3000"
echo ""
echo "📊 View logs:"
echo "   az container logs --resource-group $RESOURCE_GROUP --name $ACI_NAME --follow"
echo ""
echo "🧹 Delete when done:"
echo "   az group delete --name $RESOURCE_GROUP --yes"

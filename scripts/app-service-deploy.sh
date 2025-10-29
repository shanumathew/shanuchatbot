#!/bin/bash
# Azure App Service Deployment Script
# Deploy React Chatbot to Azure App Service

set -e

echo "=========================================="
echo "Azure App Service Setup"
echo "=========================================="

# Variables
RESOURCE_GROUP="react-chatbot-rg"
APP_SERVICE_PLAN="react-chatbot-plan"
APP_SERVICE_NAME="react-chatbot-app"
LOCATION="eastus"
SKU="B2"
ACR_REGISTRY="shanumathew"

echo ""
echo "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  App Service Plan: $APP_SERVICE_PLAN"
echo "  App Service: $APP_SERVICE_NAME"
echo "  Location: $LOCATION"
echo "  SKU: $SKU (Basic)"
echo ""

# Step 1: Create resource group (if not exists)
echo "Step 1: Creating Resource Group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Step 2: Create App Service Plan
echo "Step 2: Creating App Service Plan..."
az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RESOURCE_GROUP \
  --sku $SKU \
  --is-linux

echo "✓ App Service Plan created"

# Step 3: Create Web App with Docker image
echo "Step 3: Creating Web App with Docker Container..."
ACR_LOGIN_SERVER="${ACR_REGISTRY}.azurecr.io"
ACR_USERNAME=$(az acr credential show --name $ACR_REGISTRY --resource-group $RESOURCE_GROUP --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name $ACR_REGISTRY --resource-group $RESOURCE_GROUP --query passwords[0].value -o tsv)

az webapp create \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --name $APP_SERVICE_NAME \
  --deployment-container-image-name "${ACR_LOGIN_SERVER}/react-chatbot:latest" \
  --docker-registry-server-url "https://${ACR_LOGIN_SERVER}" \
  --docker-registry-server-user $ACR_USERNAME \
  --docker-registry-server-password $ACR_PASSWORD

echo "✓ Web App created"

# Step 4: Configure web app settings
echo "Step 4: Configuring Web App Settings..."
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --settings \
    WEBSITES_ENABLE_APP_SERVICE_STORAGE=false \
    DOCKER_REGISTRY_SERVER_URL="https://${ACR_LOGIN_SERVER}" \
    DOCKER_REGISTRY_SERVER_USERNAME=$ACR_USERNAME \
    DOCKER_REGISTRY_SERVER_PASSWORD=$ACR_PASSWORD \
    NODE_ENV=production \
    WEBSITE_HEALTHCHECK_MAXPINGFAILURES=3

echo "✓ App settings configured"

# Step 5: Configure container port
echo "Step 5: Configuring Container Port..."
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME \
  --settings WEBSITES_PORT=3000

echo "✓ Port configured to 3000"

# Step 6: Enable continuous deployment
echo "Step 6: Enabling Continuous Deployment..."
az webapp deployment container config \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --enable-cd true

echo "✓ Continuous deployment enabled"

# Step 7: Get webhook URL
echo "Step 7: Getting Webhook URL..."
WEBHOOK_URL=$(az webapp deployment container config \
  --name $APP_SERVICE_NAME \
  --resource-group $RESOURCE_GROUP \
  --query cicdUrl \
  -o tsv)

echo "✓ Webhook URL: $WEBHOOK_URL"

# Step 8: Restart web app
echo "Step 8: Restarting Web App..."
az webapp restart \
  --resource-group $RESOURCE_GROUP \
  --name $APP_SERVICE_NAME

echo "✓ Web App restarted"

# Step 9: Get app URL
echo ""
echo "=========================================="
echo "DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""

APP_URL="https://${APP_SERVICE_NAME}.azurewebsites.net"
echo "Web App URL: $APP_URL"
echo ""
echo "Status: Check status after 30 seconds..."
az webapp show --resource-group $RESOURCE_GROUP --name $APP_SERVICE_NAME --query "{name:name, state:state, defaultHostName:defaultHostName}" -o table

echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo "1. Access your app:"
echo "   $APP_URL"
echo ""
echo "2. View logs:"
echo "   az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_SERVICE_NAME"
echo ""
echo "3. Enable HTTPS:"
echo "   az webapp update --resource-group $RESOURCE_GROUP --name $APP_SERVICE_NAME --https-only true"
echo ""
echo "4. Configure custom domain:"
echo "   az webapp config hostname add --resource-group $RESOURCE_GROUP --webapp-name $APP_SERVICE_NAME --hostname your-domain.com"
echo ""
echo "5. Scale up:"
echo "   az appservice plan update --resource-group $RESOURCE_GROUP --name $APP_SERVICE_PLAN --sku P1V2"
echo ""
echo "6. Delete when done:"
echo "   az group delete --name $RESOURCE_GROUP --yes"
echo ""

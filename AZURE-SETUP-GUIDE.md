# Azure Deployment Setup Guide

## 🚀 Prerequisites

- Azure Account (Free or Paid)
- Azure CLI installed
- Docker installed
- GitHub account with your repository

## 📋 Step 1: Azure CLI Setup

### Install Azure CLI

**Windows (PowerShell)**:
```powershell
# Using Chocolatey
choco install azure-cli

# Or using MSI installer
# Download from: https://aka.ms/installazurecliwindows
```

**Mac**:
```bash
brew install azure-cli
```

**Linux**:
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Verify Installation

```bash
az --version
```

### Login to Azure

```bash
az login
```

This opens a browser window. Sign in with your Azure account credentials.

### Set Default Subscription

```bash
# List subscriptions
az account list --output table

# Set default subscription
az account set --subscription "subscription-id"

# Verify
az account show
```

---

## 📦 Step 2: Create Resource Group

### Create Resource Group

```bash
# Set variables
RESOURCE_GROUP=chatbot-rg
LOCATION=eastus
APP_NAME=react-chatbot

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

echo "✅ Resource Group Created: $RESOURCE_GROUP"
```

### Verify Resource Group

```bash
az group show --name $RESOURCE_GROUP
```

---

## 🐳 Step 3: Azure Container Registry (ACR)

### Create Container Registry

```bash
# Create ACR
REGISTRY_NAME=reactchatbotacr  # Must be globally unique and lowercase

az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME \
  --sku Basic \
  --admin-enabled true

echo "✅ Container Registry Created: $REGISTRY_NAME"
```

### Get Registry Login Credentials

```bash
# Get login credentials
az acr credential show \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME

# Output includes username and passwords
# Save these for Docker login
```

### Login to ACR

```bash
# Get login credentials
REGISTRY_USERNAME=$(az acr credential show \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME \
  --query "username" -o tsv)

REGISTRY_PASSWORD=$(az acr credential show \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME \
  --query "passwords[0].value" -o tsv)

# Login to Docker
echo $REGISTRY_PASSWORD | docker login $REGISTRY_NAME.azurecr.io \
  --username $REGISTRY_USERNAME \
  --password-stdin

# Success: Login Succeeded
```

---

## 🏗️ Step 4: Push Docker Image to ACR

### Build and Push Image

```bash
# Build image
docker build -t react-chatbot:latest .

# Tag for ACR
docker tag react-chatbot:latest \
  $REGISTRY_NAME.azurecr.io/react-chatbot:latest

# Push to ACR
docker push $REGISTRY_NAME.azurecr.io/react-chatbot:latest

echo "✅ Image pushed to ACR"
```

### Verify Image in ACR

```bash
# List images in registry
az acr repository list \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME

# Show image details
az acr repository show \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME \
  --repository react-chatbot

# List tags
az acr repository show-tags \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME \
  --repository react-chatbot
```

---

## ☁️ Step 5: Deploy to Azure Container Instances (ACI)

### Option A: Quick Deployment with ACI

```bash
# Set container details
CONTAINER_NAME=react-chatbot-container
IMAGE=$REGISTRY_NAME.azurecr.io/react-chatbot:latest
PORT=3000

# Create container instance
az container create \
  --resource-group $RESOURCE_GROUP \
  --name $CONTAINER_NAME \
  --image $IMAGE \
  --registry-login-server $REGISTRY_NAME.azurecr.io \
  --registry-username $REGISTRY_USERNAME \
  --registry-password $REGISTRY_PASSWORD \
  --ports $PORT \
  --protocol TCP \
  --cpu 1 \
  --memory 1 \
  --environment-variables \
    NODE_ENV=production \
    VITE_APP_TITLE="React Chatbot on Azure" \
  --dns-name-label $APP_NAME \
  --restart-policy OnFailure

echo "✅ Container Instance Created"
```

### Get Container URL

```bash
# Get container IP and FQDN
az container show \
  --resource-group $RESOURCE_GROUP \
  --name $CONTAINER_NAME \
  --query "ipAddress.fqdn" \
  --output tsv

# Access URL: http://react-chatbot.eastus.azurecontainer.io:3000
```

### Monitor Container

```bash
# Get container status
az container show \
  --resource-group $RESOURCE_GROUP \
  --name $CONTAINER_NAME

# View logs
az container logs \
  --resource-group $RESOURCE_GROUP \
  --name $CONTAINER_NAME

# Follow logs in real-time
az container logs \
  --resource-group $RESOURCE_GROUP \
  --name $CONTAINER_NAME \
  --follow
```

---

## 🎯 Step 6: Alternative - Deploy to Azure App Service

### Create App Service Plan

```bash
# Create App Service Plan
PLAN_NAME=chatbot-plan

az appservice plan create \
  --name $PLAN_NAME \
  --resource-group $RESOURCE_GROUP \
  --sku B1 \
  --is-linux

echo "✅ App Service Plan Created: $PLAN_NAME"
```

### Create Web App

```bash
# Create Web App for Containers
WEB_APP_NAME=react-chatbot-app

az webapp create \
  --name $WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --plan $PLAN_NAME \
  --deployment-container-image-name $IMAGE

echo "✅ Web App Created: $WEB_APP_NAME"
```

### Configure Container Registry

```bash
# Set ACR credentials in Web App
az webapp config container set \
  --name $WEB_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --docker-custom-image-name $IMAGE \
  --docker-registry-server-url https://$REGISTRY_NAME.azurecr.io \
  --docker-registry-server-user $REGISTRY_USERNAME \
  --docker-registry-server-password $REGISTRY_PASSWORD

echo "✅ Container Registry Configured"
```

### Configure Environment Variables

```bash
# Set app settings
az webapp config appsettings set \
  --resource-group $RESOURCE_GROUP \
  --name $WEB_APP_NAME \
  --settings \
    NODE_ENV=production \
    VITE_APP_TITLE="React Chatbot on Azure"

echo "✅ App Settings Configured"
```

### Get Web App URL

```bash
# Get URL
az webapp show \
  --resource-group $RESOURCE_GROUP \
  --name $WEB_APP_NAME \
  --query "defaultHostName" \
  --output tsv

# Access: https://react-chatbot-app.azurewebsites.net
```

---

## 🔄 Step 7: Enable Continuous Deployment

### Deploy from GitHub

```bash
# Get deployment credentials
az webapp deployment user set \
  --user-name <deployment-username> \
  --password <deployment-password>

# Create deployment slot (optional)
az webapp deployment slot create \
  --resource-group $RESOURCE_GROUP \
  --name $WEB_APP_NAME \
  --slot staging

# Enable continuous deployment from GitHub
# Go to: Azure Portal → Web App → Deployment Center
# Or use GitHub Actions (see below)
```

### GitHub Actions Workflow

Create `.github/workflows/azure-deploy.yml`:

```yaml
name: Deploy to Azure

on:
  push:
    branches: [main, master]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Build and push image
        run: |
          docker build -t ${{ secrets.REGISTRY_NAME }}.azurecr.io/react-chatbot:latest .
          docker push ${{ secrets.REGISTRY_NAME }}.azurecr.io/react-chatbot:latest
      
      - name: Deploy to Web App
        uses: azure/webapps-deploy@v2
        with:
          app-name: react-chatbot-app
          images: ${{ secrets.REGISTRY_NAME }}.azurecr.io/react-chatbot:latest
```

---

## 🌐 Step 8: Set Up Custom Domain

### Add Custom Domain

```bash
# Add custom domain to Web App
az webapp config hostname add \
  --resource-group $RESOURCE_GROUP \
  --webapp-name $WEB_APP_NAME \
  --hostname your-domain.com

# You'll need to add DNS records:
# Type: CNAME
# Name: www
# Value: react-chatbot-app.azurewebsites.net
```

---

## 🔒 Step 9: Enable SSL/TLS Certificate

### Option A: Free Azure-Managed Certificate

```bash
# Create certificate binding
az webapp config ssl bind \
  --resource-group $RESOURCE_GROUP \
  --name $WEB_APP_NAME \
  --certificate-name mycert \
  --ssl-type SNI
```

### Option B: Let's Encrypt Certificate

```bash
# Use Azure App Service Certificate (paid option)
# Or use Let's Encrypt for free via GitHub Actions
```

---

## 📊 Step 10: Monitoring and Logging

### Enable Application Insights

```bash
# Create Application Insights
INSIGHTS_NAME=chatbot-insights

az monitor app-insights component create \
  --app $INSIGHTS_NAME \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP \
  --kind web

# Get instrumentation key
az monitor app-insights component show \
  --resource-group $RESOURCE_GROUP \
  --app $INSIGHTS_NAME \
  --query "instrumentationKey" \
  --output tsv
```

### Configure Logging

```bash
# Enable logging for Web App
az webapp log config \
  --resource-group $RESOURCE_GROUP \
  --name $WEB_APP_NAME \
  --application-logging filesystem \
  --level information \
  --detailed-error-messages

# Stream logs
az webapp log tail \
  --resource-group $RESOURCE_GROUP \
  --name $WEB_APP_NAME
```

### Create Alerts

```bash
# Create CPU alert
az monitor metrics alert create \
  --resource-group $RESOURCE_GROUP \
  --name "High CPU Alert" \
  --scopes /subscriptions/{subscription}/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$WEB_APP_NAME \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m \
  --evaluation-frequency 1m
```

---

## 🔐 Step 11: Security Configuration

### Enable Managed Identity

```bash
# Enable system-assigned managed identity
az webapp identity assign \
  --resource-group $RESOURCE_GROUP \
  --name $WEB_APP_NAME

# Get principal ID
PRINCIPAL_ID=$(az webapp identity show \
  --resource-group $RESOURCE_GROUP \
  --name $WEB_APP_NAME \
  --query principalId -o tsv)

echo "Principal ID: $PRINCIPAL_ID"
```

### Set Up Network Rules

```bash
# Create Virtual Network (optional)
VNET_NAME=chatbot-vnet
SUBNET_NAME=chatbot-subnet

az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name $VNET_NAME \
  --subnet-name $SUBNET_NAME

# Configure firewall rules
az webapp config access-restriction add \
  --resource-group $RESOURCE_GROUP \
  --name $WEB_APP_NAME \
  --rule-name AllowAzure \
  --action Allow \
  --priority 100 \
  --service-tag AzureCloud
```

---

## 📈 Step 12: Auto Scaling

### Configure Auto Scale

```bash
# Create autoscale settings
az monitor autoscale create \
  --resource-group $RESOURCE_GROUP \
  --resource-name $PLAN_NAME \
  --resource-type "Microsoft.Web/serverfarms" \
  --min-count 1 \
  --max-count 3 \
  --count 1

# Add scale rule (CPU-based)
az monitor autoscale rule create \
  --resource-group $RESOURCE_GROUP \
  --autoscale-name chatbot-autoscale \
  --condition "Percentage CPU > 70 avg 5m" \
  --scale out 1
```

---

## 🔄 Step 13: GitHub Actions Integration

### Create Azure Service Principal

```bash
# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)

# Create service principal
az ad sp create-for-rbac \
  --name "react-chatbot-github" \
  --role Contributor \
  --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP \
  --json-auth

# Output: Save this JSON as AZURE_CREDENTIALS secret
```

### Add GitHub Secrets

1. Go to GitHub repository → **Settings → Secrets and variables → Actions**
2. Add secrets:

```
AZURE_CREDENTIALS: (JSON from above)
REGISTRY_NAME: reactchatbotacr
REGISTRY_USERNAME: (from ACR)
REGISTRY_PASSWORD: (from ACR)
RESOURCE_GROUP: chatbot-rg
WEB_APP_NAME: react-chatbot-app
```

---

## 🧹 Step 14: Cleanup (If Needed)

### Delete Resources

```bash
# Delete resource group (deletes all resources)
az group delete --name $RESOURCE_GROUP --yes

# Or delete specific resources:

# Delete Web App
az webapp delete \
  --resource-group $RESOURCE_GROUP \
  --name $WEB_APP_NAME

# Delete Container Instance
az container delete \
  --resource-group $RESOURCE_GROUP \
  --name $CONTAINER_NAME \
  --yes

# Delete Container Registry
az acr delete \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME \
  --yes
```

---

## 💰 Cost Estimation

### Azure Container Instances
- CPU: ~$0.0015 per CPU hour
- Memory: ~$0.000625 per GB hour
- Estimate: **$5-15/month** (minimal usage)

### Azure App Service (B1 Plan)
- **~$50-80/month**

### Free Options
- **Azure Free Tier**: 12 months free access to services

---

## ✅ Quick Reference Commands

```bash
# Login
az login

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create container registry
az acr create --name $REGISTRY_NAME --resource-group $RESOURCE_GROUP --sku Basic

# Push image
docker push $REGISTRY_NAME.azurecr.io/react-chatbot:latest

# Deploy to ACI
az container create --image $IMAGE --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME

# Deploy to App Service
az webapp create --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP --plan $PLAN_NAME

# View logs
az container logs --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME --follow

# Get URL
az container show --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME --query "ipAddress.fqdn"
```

---

## ✅ Deployment Checklist

- [ ] Azure Account created
- [ ] Azure CLI installed and logged in
- [ ] Resource Group created
- [ ] Container Registry created
- [ ] Docker image built and pushed
- [ ] Container/Web App deployed
- [ ] Service URL accessible
- [ ] GitHub secrets configured
- [ ] Monitoring enabled
- [ ] Alerts set up (optional)

---

## 🎯 Next Steps

1. **Monitor your service**: `az container logs --follow`
2. **View metrics**: Azure Portal → Monitor
3. **Set up custom domain**: Add DNS records
4. **Enable SSL**: Configure certificate
5. **Setup auto-deployment**: Configure GitHub Actions

---

## 🆘 Troubleshooting

### Container not starting

```bash
# Check container details
az container show \
  --resource-group $RESOURCE_GROUP \
  --name $CONTAINER_NAME

# View logs
az container logs \
  --resource-group $RESOURCE_GROUP \
  --name $CONTAINER_NAME
```

### Image not found in ACR

```bash
# Verify image exists
az acr repository list \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME

# Re-push image
docker push $REGISTRY_NAME.azurecr.io/react-chatbot:latest
```

### Can't connect to service

1. Check Network Security Group (NSG) rules
2. Verify port 3000 is exposed
3. Check Azure Firewall settings
4. Verify DNS propagation

---

For more info, see [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)

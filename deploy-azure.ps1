# Azure Deployment Script for React Chatbot
# Run this with: powershell -ExecutionPolicy Bypass -File deploy-azure.ps1

Write-Host "🚀 Azure Deployment Script for React Chatbot" -ForegroundColor Cyan

# Step 1: Login to Azure
Write-Host "`n📝 Step 1: Logging in to Azure..." -ForegroundColor Yellow
az login

# Step 2: Get Subscription
Write-Host "`n📋 Getting current subscription..." -ForegroundColor Yellow
$SUBSCRIPTION_ID = az account show --query id -o tsv
$SUBSCRIPTION_NAME = az account show --query name -o tsv
Write-Host "Subscription: $SUBSCRIPTION_NAME ($SUBSCRIPTION_ID)" -ForegroundColor Green

# Step 3: Set variables
$RESOURCE_GROUP = "react-chatbot-rg"
$LOCATION = "eastus"
$ACR_NAME = "reactchatbotacr$(Get-Random -Minimum 1000 -Maximum 9999)"
$IMAGE_NAME = "react-chatbot"
$IMAGE_TAG = "latest"
$ACI_NAME = "react-chatbot-aci"
$APPSERVICE_PLAN = "react-chatbot-plan"
$APPSERVICE_NAME = "react-chatbot-app-$(Get-Random -Minimum 1000 -Maximum 9999)"

Write-Host "`n🔧 Configuration:" -ForegroundColor Cyan
Write-Host "Resource Group: $RESOURCE_GROUP"
Write-Host "Location: $LOCATION"
Write-Host "Container Registry: $ACR_NAME"
Write-Host "Image Name: $IMAGE_NAME"
Write-Host "ACI Instance: $ACI_NAME"
Write-Host "App Service: $APPSERVICE_NAME"

# Step 4: Create Resource Group
Write-Host "`n📁 Step 2: Creating Resource Group..." -ForegroundColor Yellow
az group create --name $RESOURCE_GROUP --location $LOCATION
Write-Host "✅ Resource Group created" -ForegroundColor Green

# Step 5: Create Container Registry
Write-Host "`n🐳 Step 3: Creating Azure Container Registry..." -ForegroundColor Yellow
az acr create `
  --resource-group $RESOURCE_GROUP `
  --name $ACR_NAME `
  --sku Basic `
  --admin-enabled true

Write-Host "✅ Container Registry created: $ACR_NAME" -ForegroundColor Green

# Step 6: Get ACR credentials
Write-Host "`n🔑 Step 4: Getting ACR credentials..." -ForegroundColor Yellow
$ACR_LOGIN_SERVER = az acr show --resource-group $RESOURCE_GROUP --name $ACR_NAME --query loginServer -o tsv
$ACR_USERNAME = az acr credential show --resource-group $RESOURCE_GROUP --name $ACR_NAME --query username -o tsv
$ACR_PASSWORD = az acr credential show --resource-group $RESOURCE_GROUP --name $ACR_NAME --query passwords[0].value -o tsv

Write-Host "ACR Login Server: $ACR_LOGIN_SERVER" -ForegroundColor Green
Write-Host "ACR Username: $ACR_USERNAME" -ForegroundColor Green

# Step 7: Build Docker image in Azure
Write-Host "`n🔨 Step 5: Building Docker image in Azure Container Registry..." -ForegroundColor Yellow
az acr build `
  --resource-group $RESOURCE_GROUP `
  --registry $ACR_NAME `
  --image "$IMAGE_NAME`:$IMAGE_TAG" `
  .

Write-Host "✅ Docker image built and pushed to ACR" -ForegroundColor Green

# Step 8: Deploy to Azure Container Instances (ACI)
Write-Host "`n☁️  Step 6: Deploying to Azure Container Instances..." -ForegroundColor Yellow
az container create `
  --resource-group $RESOURCE_GROUP `
  --name $ACI_NAME `
  --image "$ACR_LOGIN_SERVER/$IMAGE_NAME`:$IMAGE_TAG" `
  --cpu 1 `
  --memory 1 `
  --registry-login-server $ACR_LOGIN_SERVER `
  --registry-username $ACR_USERNAME `
  --registry-password $ACR_PASSWORD `
  --ports 3000 `
  --dns-name-label "react-chatbot-$(Get-Random -Minimum 1000 -Maximum 9999)" `
  --environment-variables "NODE_ENV=production" `
  --restart-policy OnFailure

Write-Host "✅ Container Instance created: $ACI_NAME" -ForegroundColor Green

# Step 9: Get ACI URL
Write-Host "`n🌐 Step 7: Getting Container Instance URL..." -ForegroundColor Yellow
$ACI_FQDN = az container show `
  --resource-group $RESOURCE_GROUP `
  --name $ACI_NAME `
  --query ipAddress.fqdn -o tsv
$ACI_IP = az container show `
  --resource-group $RESOURCE_GROUP `
  --name $ACI_NAME `
  --query ipAddress.ip -o tsv

Write-Host "Container Instance URL: http://$ACI_FQDN:3000" -ForegroundColor Green
Write-Host "Container Instance IP: $ACI_IP" -ForegroundColor Green

# Step 10: Display logs
Write-Host "`n📊 Step 8: Container logs (last 10 lines)..." -ForegroundColor Yellow
az container logs --resource-group $RESOURCE_GROUP --name $ACI_NAME --tail 10

# Step 11: Create App Service Plan (optional alternative)
Write-Host "`n💡 Step 9: Creating App Service Plan (Optional)..." -ForegroundColor Yellow
az appservice plan create `
  --name $APPSERVICE_PLAN `
  --resource-group $RESOURCE_GROUP `
  --sku B1 `
  --is-linux

# Step 12: Create Web App
Write-Host "`n🌍 Step 10: Creating App Service Web App..." -ForegroundColor Yellow
az webapp create `
  --resource-group $RESOURCE_GROUP `
  --plan $APPSERVICE_PLAN `
  --name $APPSERVICE_NAME `
  --deployment-container-image-name "$ACR_LOGIN_SERVER/$IMAGE_NAME`:$IMAGE_TAG" `
  --docker-registry-server-url "https://$ACR_LOGIN_SERVER" `
  --docker-registry-server-user $ACR_USERNAME `
  --docker-registry-server-password $ACR_PASSWORD

Write-Host "✅ App Service created: $APPSERVICE_NAME" -ForegroundColor Green

# Step 13: Configure Web App
Write-Host "`n⚙️  Step 11: Configuring Web App..." -ForegroundColor Yellow
az webapp config appsettings set `
  --resource-group $RESOURCE_GROUP `
  --name $APPSERVICE_NAME `
  --settings "WEBSITES_ENABLE_APP_SERVICE_STORAGE=false" `
  "DOCKER_REGISTRY_SERVER_URL=https://$ACR_LOGIN_SERVER" `
  "DOCKER_REGISTRY_SERVER_USERNAME=$ACR_USERNAME" `
  "DOCKER_REGISTRY_SERVER_PASSWORD=$ACR_PASSWORD" `
  "NODE_ENV=production"

# Step 14: Restart Web App
Write-Host "`n🔄 Step 12: Restarting Web App..." -ForegroundColor Yellow
az webapp restart --resource-group $RESOURCE_GROUP --name $APPSERVICE_NAME

Write-Host "✅ Web App restarted" -ForegroundColor Green

# Step 15: Get Web App URL
Write-Host "`n🎯 Step 13: Getting Web App URL..." -ForegroundColor Yellow
$WEBAPP_URL = az webapp show --resource-group $RESOURCE_GROUP --name $APPSERVICE_NAME --query defaultHostName -o tsv
Write-Host "Web App URL: https://$WEBAPP_URL" -ForegroundColor Green

# Step 16: Enable monitoring
Write-Host "`n📊 Step 14: Enabling Application Insights..." -ForegroundColor Yellow
$APPINSIGHTS_NAME = "react-chatbot-insights"
az monitor app-insights component create `
  --app $APPINSIGHTS_NAME `
  --location $LOCATION `
  --resource-group $RESOURCE_GROUP `
  --application-type web

Write-Host "✅ Application Insights enabled" -ForegroundColor Green

# Summary
Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     🎉 DEPLOYMENT COMPLETE! 🎉                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n📋 Deployment Summary:" -ForegroundColor Green
Write-Host "Resource Group: $RESOURCE_GROUP" -ForegroundColor White
Write-Host "Location: $LOCATION" -ForegroundColor White
Write-Host ""
Write-Host "🐳 Azure Container Instances:" -ForegroundColor Yellow
Write-Host "  Name: $ACI_NAME" -ForegroundColor White
Write-Host "  URL: http://$ACI_FQDN:3000" -ForegroundColor Cyan
Write-Host "  IP: $ACI_IP" -ForegroundColor White
Write-Host ""
Write-Host "🌍 App Service:" -ForegroundColor Yellow
Write-Host "  Name: $APPSERVICE_NAME" -ForegroundColor White
Write-Host "  URL: https://$WEBAPP_URL" -ForegroundColor Cyan
Write-Host ""
Write-Host "📦 Container Registry:" -ForegroundColor Yellow
Write-Host "  Name: $ACR_NAME" -ForegroundColor White
Write-Host "  Login Server: $ACR_LOGIN_SERVER" -ForegroundColor White
Write-Host ""
Write-Host "⏱️  Estimated Costs:" -ForegroundColor Yellow
Write-Host "  ACI: ~\$30-50/month" -ForegroundColor White
Write-Host "  App Service (B1): ~\$12.50/month" -ForegroundColor White
Write-Host "  Container Registry: ~\$5/month" -ForegroundColor White

Write-Host "`n💾 Save these details securely!" -ForegroundColor Magenta
Write-Host "Resource Group: $RESOURCE_GROUP"
Write-Host "Container Registry: $ACR_NAME"
Write-Host "ACR Login Server: $ACR_LOGIN_SERVER"
Write-Host "ACI FQDN: $ACI_FQDN"
Write-Host "App Service: $APPSERVICE_NAME"

Write-Host "`n📚 Useful commands:" -ForegroundColor Cyan
Write-Host "  View ACI logs: az container logs --resource-group $RESOURCE_GROUP --name $ACI_NAME --follow"
Write-Host "  View Web App logs: az webapp log tail --resource-group $RESOURCE_GROUP --name $APPSERVICE_NAME"
Write-Host "  Delete all: az group delete --name $RESOURCE_GROUP --yes"

Write-Host "`n✨ Your chatbot is now live!" -ForegroundColor Green

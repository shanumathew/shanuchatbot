# Azure CLI Installation & Setup

## Windows Installation

### Option 1: Direct Download (Recommended - No Admin)
1. Go to: https://aka.ms/installazurecliwindows
2. Download the `.msi` installer
3. Run the installer
4. Close and reopen PowerShell/CMD
5. Verify: `az --version`

### Option 2: Windows Package Manager
```powershell
winget install Microsoft.AzureCLI
```

### Option 3: Chocolatey (Admin Required)
```powershell
# Run as Administrator
choco install azure-cli
```

### Option 4: Python pip
```bash
pip install azure-cli
```

---

## Quick Start After Installation

### 1. Login to Azure
```powershell
az login
```
This opens a browser to authenticate. Close the browser when done.

### 2. List Subscriptions
```powershell
az account list --output table
```

### 3. Set Active Subscription
```powershell
az account set --subscription "Subscription Name or ID"
```

### 4. Verify Login
```powershell
az account show
```

---

## Deploy Your Chatbot

### 1. Navigate to Project Directory
```powershell
cd "C:\Users\shanu.Nustartz\Desktop\chatbot devops"
```

### 2. Run Deployment Script
```powershell
powershell -ExecutionPolicy Bypass -File deploy-azure.ps1
```

This script will:
- Create a Resource Group
- Create Azure Container Registry (ACR)
- Build and push Docker image
- Deploy to Azure Container Instances (ACI)
- Create App Service (optional)
- Enable monitoring

---

## What Gets Created

### Azure Container Instances (Quick & Easy)
- **Cost**: ~$30-50/month
- **URL**: `http://your-app.azurecontainer.io:3000`
- **Startup**: ~5-10 seconds

### App Service (Production)
- **Cost**: ~$12.50/month (B1 tier)
- **URL**: `https://your-app.azurewebsites.net`
- **Startup**: ~30 seconds
- **Built-in**: Auto-scaling, SSL, deployment slots

### Container Registry
- **Cost**: ~$5/month (Basic tier)
- **Purpose**: Store Docker images

---

## After Deployment

### Monitor Your App
```powershell
# View ACI logs
az container logs --resource-group react-chatbot-rg --name react-chatbot-aci --follow

# View App Service logs
az webapp log tail --resource-group react-chatbot-rg --name your-app-name
```

### Update Docker Image
```powershell
# After code changes, rebuild and push
az acr build --registry your-acr-name --image react-chatbot:latest .

# Restart ACI
az container restart --resource-group react-chatbot-rg --name react-chatbot-aci

# Redeploy App Service
az webapp deployment container config --registry-password $PASSWORD --registry-username $USERNAME --registry-url $ACR_URL --name your-app-name --resource-group react-chatbot-rg
```

### Stop Charging
```powershell
# Delete entire resource group (everything)
az group delete --name react-chatbot-rg --yes

# Or just stop the container
az container stop --resource-group react-chatbot-rg --name react-chatbot-aci
```

---

## Useful Links

- [Azure CLI Reference](https://learn.microsoft.com/en-us/cli/azure/reference-index)
- [Container Instances Docs](https://learn.microsoft.com/en-us/azure/container-instances/)
- [App Service Docs](https://learn.microsoft.com/en-us/azure/app-service/)
- [Container Registry Docs](https://learn.microsoft.com/en-us/azure/container-registry/)

---

## GitHub Actions Integration

After deployment, add these secrets to GitHub:

1. Go to: GitHub → Your Repo → Settings → Secrets and variables → Actions
2. Add new secrets:

```
AZURE_REGISTRY_LOGIN_SERVER: your-acr.azurecr.io
AZURE_REGISTRY_USERNAME: username
AZURE_REGISTRY_PASSWORD: password
AZURE_RESOURCE_GROUP: react-chatbot-rg
AZURE_ACI_NAME: react-chatbot-aci
AZURE_APPSERVICE_NAME: your-app-name
```

Then update workflow to auto-deploy on push.

---

## Troubleshooting

### "az: command not found"
- Make sure Azure CLI is installed: https://aka.ms/installazurecliwindows
- Restart PowerShell/CMD after installation

### "Not authenticated"
```powershell
az login
```

### "Image not found in registry"
```powershell
# Check images
az acr repository list --name your-acr-name

# Rebuild and push
az acr build --registry your-acr-name --image react-chatbot:latest .
```

### "Port 3000 not accessible"
- Make sure Dockerfile exposes port 3000
- Check Network Security Group rules
- Verify container is running: `az container show --resource-group react-chatbot-rg --name react-chatbot-aci`

---

## Cost Breakdown

**Monthly Estimate** (assuming always running):
- ACI (0.25 vCPU, 1GB RAM): $30
- App Service (B1): $12.50
- Container Registry (Basic): $5
- **Total: ~$47.50/month**

To reduce costs:
- Use ACI (cheaper for simple apps)
- Scale down during low traffic
- Use auto-shutdown schedules
- Check billing in Azure Portal

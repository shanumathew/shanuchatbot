# Azure Deployment - Step by Step (No CLI Required)

## ⚡ Quick Start - Azure Portal Method

If you want to deploy immediately without CLI, follow these steps in Azure Portal:

### Step 1: Create an Azure Account
- Go to https://azure.microsoft.com/free/
- Sign up (get $200 free credits for 30 days)

### Step 2: Access Azure Portal
- Go to https://portal.azure.com
- Sign in with your credentials

### Step 3: Create a Resource Group
1. Search for "Resource groups"
2. Click "Create"
3. Fill in:
   - **Subscription**: Your subscription
   - **Resource Group name**: `react-chatbot-rg`
   - **Region**: `East US`
4. Click "Review + create" → "Create"

### Step 4: Create Container Registry
1. Search for "Container registries"
2. Click "Create"
3. Fill in:
   - **Subscription**: Your subscription
   - **Resource group**: `react-chatbot-rg`
   - **Registry name**: `reactchatbot<random-numbers>` (must be lowercase, unique)
   - **Location**: `East US`
   - **SKU**: `Basic`
4. Click "Create"

### Step 5: Build & Push Docker Image
Once registry is created:

1. Open your project directory in terminal
2. Get ACR login credentials from Azure Portal:
   - Go to your Container Registry → Access keys
   - Copy: Registry name, Username, Password
   
3. Login to ACR:
```bash
docker login reactchatbot<name>.azurecr.io -u <username> -p <password>
```

4. Tag your image:
```bash
docker tag react-chatbot:latest reactchatbot<name>.azurecr.io/react-chatbot:latest
```

5. Push to ACR:
```bash
docker push reactchatbot<name>.azurecr.io/react-chatbot:latest
```

### Step 6: Deploy to Container Instances (Easy - ~5 mins)

1. Search for "Container Instances" in Azure Portal
2. Click "Create"
3. Fill in:
   - **Resource group**: `react-chatbot-rg`
   - **Container name**: `react-chatbot-aci`
   - **Region**: `East US`
   - **Image source**: `Azure Container Registry`
   - **Registry**: Select your registry
   - **Image**: `react-chatbot`
   - **Image tag**: `latest`
   - **OS type**: `Linux`
   - **CPU cores**: `1`
   - **Memory (GB)**: `1`
   - **DNS name label**: `react-chatbot-unique`
   - **Port**: `3000`
   - **Protocol**: `TCP`

4. Click "Review + create" → "Create"

5. Wait for deployment (2-3 minutes)

6. Once deployed, go to your resource → Overview
   - You'll see the **FQDN**: `react-chatbot-unique.azurecontainer.io`
   - Your app URL: `http://react-chatbot-unique.azurecontainer.io:3000`

---

## Alternative: Deploy to App Service (Better for Production)

### Step 1-5: Same as above (create RG, ACR, push image)

### Step 6: Create App Service Plan
1. Search for "App Service plans"
2. Click "Create"
3. Fill in:
   - **Resource group**: `react-chatbot-rg`
   - **Name**: `react-chatbot-plan`
   - **Operating System**: `Linux`
   - **Region**: `East US`
   - **Pricing tier**: `B1` (Basic) - $12.50/month

### Step 7: Create Web App
1. Search for "App Services"
2. Click "Create"
3. Fill in:
   - **Resource group**: `react-chatbot-rg`
   - **Name**: `react-chatbot-app` (must be globally unique)
   - **Publish**: `Docker Container`
   - **Operating System**: `Linux`
   - **Region**: `East US`
   - **App Service plan**: Select `react-chatbot-plan`

### Step 8: Configure Docker
1. Go to your Web App → Deployment center
2. Configure container settings:
   - **Registry**: Select your ACR
   - **Image**: `react-chatbot`
   - **Tag**: `latest`
3. Click "Save"

4. Your app will deploy automatically
5. URL: `https://react-chatbot-app.azurewebsites.net`

---

## 💰 Cost Breakdown

### Container Instances
- **Compute**: ~$0.0000015/second (0.25 vCPU, 1GB)
- **Monthly**: ~$40
- **Startup time**: ~5-10 seconds
- **Best for**: Testing, low-traffic apps

### App Service (B1)
- **Monthly**: ~$12.50
- **Startup time**: ~30 seconds
- **Best for**: Production, always-on apps
- **Includes**: Auto-scaling, deployment slots, SSL

### Container Registry (Basic)
- **Monthly**: ~$5
- **Includes**: 10 GB storage

**Total Monthly Cost**: ~$47.50 (Container Instances) or ~$47.50 (App Service + Registry)

---

## 🔄 Update Your App

### When You Make Changes:

1. Build new image:
```bash
docker build -t react-chatbot:latest .
```

2. Tag and push:
```bash
docker tag react-chatbot:latest reactchatbot<name>.azurecr.io/react-chatbot:latest
docker push reactchatbot<name>.azurecr.io/react-chatbot:latest
```

3. **For Container Instances**: Restart the container
   - Azure Portal → Your container → Restart

4. **For App Service**: Redeploy
   - Deployment automatically triggers on image update

---

## 🆘 Troubleshooting

### Can't access the app
- Check if Container Instance/App Service status is "Running"
- Check firewall rules allow port 3000/3001
- Check Application logs in Azure Portal

### Image not showing in registry
- Make sure docker push succeeded
- Check registry name is correct
- Verify authentication credentials

### High costs
- Stop the Container Instance if not needed
- Use App Service with auto-scale to scale down to 0

### Delete Everything (Stop Charging)
Go to Resource Groups → `react-chatbot-rg` → Delete resource group

---

## 📊 Monitor Your App

### View Logs
1. Go to your Container Instance/Web App
2. Click "Logs" or "Log stream"
3. See real-time application output

### Application Insights (Monitoring)
1. Go to your Web App → Application Insights
2. Enable it
3. Monitor performance, errors, dependencies

---

## ✅ Next Steps

1. **Create Azure Account** (if needed): https://azure.microsoft.com/free/
2. **Follow steps above** in Azure Portal
3. **Test your app**: Visit the URL
4. **Set custom domain** (optional):
   - Buy domain from GoDaddy, NameCheap, etc.
   - Point DNS to Azure
   - Configure in Azure Portal

5. **Enable HTTPS**:
   - App Service: Managed SSL included
   - Container Instances: Configure with Nginx reverse proxy

---

## 🚀 GitHub Actions Automation

After manual deployment works, set up GitHub Actions to auto-deploy on push:

1. Go to GitHub → Your repo → Settings → Secrets
2. Add:
   - `AZURE_REGISTRY_LOGIN_SERVER`: from ACR Access keys
   - `AZURE_REGISTRY_USERNAME`: from ACR Access keys
   - `AZURE_REGISTRY_PASSWORD`: from ACR Access keys
   - `AZURE_RESOURCE_GROUP`: `react-chatbot-rg`
   - `AZURE_ACI_NAME`: `react-chatbot-aci`

3. The `.github/workflows/deploy-azure.yml` file is already created
4. On next push to master, it will auto-build and deploy!

---

## 🎓 Useful Azure CLI Commands (for future use)

Once you get Azure CLI working:

```bash
# Login
az login

# Create resource group
az group create --name react-chatbot-rg --location eastus

# Create container registry
az acr create --resource-group react-chatbot-rg --name reactchatbot1234 --sku Basic

# Build image in ACR
az acr build --registry reactchatbot1234 --image react-chatbot:latest .

# Deploy to Container Instances
az container create \
  --resource-group react-chatbot-rg \
  --name react-chatbot-aci \
  --image reactchatbot1234.azurecr.io/react-chatbot:latest \
  --cpu 1 --memory 1 \
  --registry-login-server reactchatbot1234.azurecr.io \
  --registry-username <username> \
  --registry-password <password> \
  --ports 3000 \
  --dns-name-label react-chatbot-unique

# View logs
az container logs --resource-group react-chatbot-rg --name react-chatbot-aci --follow

# Delete everything
az group delete --name react-chatbot-rg --yes
```

---

**Start with the Azure Portal steps above - they're faster and easier!** 🚀

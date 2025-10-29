# Azure Deployment Options for React Chatbot

Complete guide to deploy your React Chatbot to Azure with multiple options.

---

## 🚀 Deployment Options

### 1. **Azure App Service** (Easiest)
- ⭐ Recommended for simple web apps
- Built-in auto-scaling
- Free SSL/HTTPS
- Easy custom domains
- No Docker knowledge needed
- Cost: ~$12.50/month (B2 tier)
- Deployment time: ~5 minutes

### 2. **Azure Kubernetes Service (AKS)** (Production)
- ⭐ Recommended for production
- High availability (multiple pods)
- Auto-scaling by CPU/Memory
- Rolling updates
- Service mesh ready
- Persistent storage support
- Cost: ~$70/month + node costs (~$50/node/month)
- Deployment time: ~10-15 minutes

### 3. **Azure Container Instances (ACI)** (Quick & Cheap)
- ⭐ Recommended for testing
- No infrastructure management
- Pay per second
- Cost: ~$30-40/month
- Deployment time: ~2-3 minutes

---

## 📋 Prerequisites

### For All Options:
```bash
# Install Azure CLI
pip install azure-cli

# Login to Azure
az login

# Set subscription
az account set --subscription "Your Subscription ID"
```

### For AKS Only:
```bash
# Install kubectl
az aks install-cli

# Or download from: https://kubernetes.io/docs/tasks/tools/
```

---

## 🏃 Quick Start - Azure App Service

### Step 1: Create Resource Group
```bash
az group create --name react-chatbot-rg --location eastus
```

### Step 2: Create App Service Plan
```bash
az appservice plan create \
  --name react-chatbot-plan \
  --resource-group react-chatbot-rg \
  --sku B2 \
  --is-linux
```

### Step 3: Create Web App
```bash
az webapp create \
  --resource-group react-chatbot-rg \
  --plan react-chatbot-plan \
  --name react-chatbot-app \
  --deployment-container-image-name shanumathew.azurecr.io/react-chatbot:latest \
  --docker-registry-server-url https://shanumathew.azurecr.io \
  --docker-registry-server-user shanumathew \
  --docker-registry-server-password <PASSWORD>
```

### Step 4: Configure Settings
```bash
az webapp config appsettings set \
  --resource-group react-chatbot-rg \
  --name react-chatbot-app \
  --settings \
    WEBSITES_ENABLE_APP_SERVICE_STORAGE=false \
    WEBSITES_PORT=3000 \
    NODE_ENV=production
```

### Step 5: Access Your App
```
https://react-chatbot-app.azurewebsites.net
```

---

## 🐳 Deploy to AKS (Kubernetes)

### Step 1: Create AKS Cluster
```bash
az aks create \
  --resource-group react-chatbot-rg \
  --name react-chatbot-aks \
  --node-count 3 \
  --enable-managed-identity \
  --network-plugin azure \
  --enable-cluster-autoscaling \
  --min-count 2 \
  --max-count 10
```

### Step 2: Get Credentials
```bash
az aks get-credentials \
  --resource-group react-chatbot-rg \
  --name react-chatbot-aks
```

### Step 3: Create Namespace
```bash
kubectl create namespace react-chatbot
```

### Step 4: Create Image Pull Secret
```bash
kubectl create secret docker-registry acr-secret \
  --docker-server=shanumathew.azurecr.io \
  --docker-username=shanumathew \
  --docker-password=<PASSWORD> \
  -n react-chatbot
```

### Step 5: Deploy Application
```bash
kubectl apply -f k8s/deployment.yaml -n react-chatbot
```

### Step 6: Get Service URL
```bash
kubectl get svc react-chatbot-service -n react-chatbot
```

---

## 📊 Automated Scripts

### Use Provided Scripts

**For App Service:**
```bash
bash scripts/app-service-deploy.sh
```

**For AKS:**
```bash
bash scripts/aks-deploy.sh
```

---

## 🔄 Update Deployment

### Option 1: Push New Image
```bash
# Build
docker build -t react-chatbot:latest .

# Tag
docker tag react-chatbot:latest shanumathew.azurecr.io/react-chatbot:latest

# Push
docker push shanumathew.azurecr.io/react-chatbot:latest

# App Service: Auto-redeploys
# AKS: Manual redeploy
kubectl rollout restart deployment/react-chatbot -n react-chatbot
```

### Option 2: Use Ansible
```bash
python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags push
```

---

## 📊 File Structure

```
.
├── k8s/
│   └── deployment.yaml         # Kubernetes manifests
├── scripts/
│   ├── aks-deploy.sh           # AKS deployment script
│   └── app-service-deploy.sh   # App Service script
├── ansible/
│   ├── main.yml                # Build & push
│   └── inventory.ini           # Configuration
└── Dockerfile                  # Container definition
```

---

## 💰 Cost Comparison

| Option | Monthly Cost | Uptime | Best For |
|--------|-------------|--------|----------|
| **Container Instances** | $30-40 | 99% | Testing, non-critical |
| **App Service (B2)** | $50+ | 99.95% | Simple web apps |
| **AKS (3 nodes)** | $200+ | 99.99% | Production, high availability |

---

## ✅ Checklist

### Before Deployment:
- [ ] Azure CLI installed
- [ ] Logged into Azure (`az login`)
- [ ] Docker image pushed to ACR
- [ ] Resource group created
- [ ] Credentials available

### For App Service:
- [ ] App Service Plan created
- [ ] App Service created
- [ ] Container settings configured
- [ ] App restarted

### For AKS:
- [ ] AKS cluster created
- [ ] kubectl configured
- [ ] Namespace created
- [ ] Image pull secret created
- [ ] Deployment applied

---

## 🆘 Troubleshooting

### "Image not found"
```bash
# Check if image exists
az acr repository list --name shanumathew

# Rebuild and push
docker build -t react-chatbot:latest .
docker tag react-chatbot:latest shanumathew.azurecr.io/react-chatbot:latest
docker push shanumathew.azurecr.io/react-chatbot:latest
```

### "Cannot pull image"
```bash
# For AKS, verify secret
kubectl get secret acr-secret -n react-chatbot

# Recreate if needed
kubectl delete secret acr-secret -n react-chatbot
kubectl create secret docker-registry acr-secret \
  --docker-server=shanumathew.azurecr.io \
  --docker-username=shanumathew \
  --docker-password=<PASSWORD> \
  -n react-chatbot
```

### "Pod not running"
```bash
# Check logs
kubectl logs deployment/react-chatbot -n react-chatbot

# Describe pod
kubectl describe pod <POD_NAME> -n react-chatbot

# Check events
kubectl get events -n react-chatbot
```

### "Service URL is Pending"
```bash
# Wait for LoadBalancer IP
kubectl get svc react-chatbot-service -n react-chatbot --watch

# May take 1-5 minutes
```

---

## 📚 Useful Commands

### App Service
```bash
# View logs
az webapp log tail --resource-group react-chatbot-rg --name react-chatbot-app

# Enable HTTPS only
az webapp update --resource-group react-chatbot-rg --name react-chatbot-app --https-only

# Scale up
az appservice plan update --resource-group react-chatbot-rg --name react-chatbot-plan --sku P1V2
```

### AKS
```bash
# View pods
kubectl get pods -n react-chatbot

# View logs
kubectl logs deployment/react-chatbot -n react-chatbot -f

# Scale replicas
kubectl scale deployment react-chatbot --replicas 5 -n react-chatbot

# View metrics
kubectl top pods -n react-chatbot

# Port forward
kubectl port-forward svc/react-chatbot-service 3000:80 -n react-chatbot
```

---

## 🎯 Next Steps

1. **Choose deployment option** (App Service recommended for start)
2. **Run deployment script** or follow manual steps
3. **Monitor deployment** in Azure Portal
4. **Test your app** at the provided URL
5. **Configure custom domain** (optional)
6. **Setup monitoring** and alerts
7. **Implement CI/CD** with GitHub Actions

---

**Your app is ready to deploy!** 🚀

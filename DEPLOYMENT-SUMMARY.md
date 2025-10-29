# React Chatbot - Complete DevOps Setup

Your React Chatbot application is fully configured for production deployment!

## 🎯 Quick Summary

- **Application**: React 18 + TypeScript with Google Gemini AI
- **Containerization**: Docker with multi-stage builds
- **Container Registry**: Azure Container Registry (shanumathew.azurecr.io)
- **Deployment Options**: 
  - Azure Container Instances (ACI) - $30-40/month
  - Azure App Service - $50+/month
  - Azure Kubernetes Service (AKS) - $200+/month

## 📦 What's Included

### Application
- ✅ React chatbot with Gemini 2.0 Flash model
- ✅ Beautiful gradient UI with animations
- ✅ Responsive mobile design
- ✅ Production-ready build

### Docker & Containers
- ✅ Production Dockerfile (multi-stage build)
- ✅ Docker Compose for development
- ✅ Docker image pushed to Azure ACR
- ✅ Dockerfile.dev for hot reload

### Kubernetes (k8s/)
- ✅ Deployment manifests (3 replicas)
- ✅ Service configuration (LoadBalancer)
- ✅ Horizontal Pod Autoscaler (HPA)
- ✅ Pod Disruption Budget
- ✅ Resource limits and health checks

### Automation
- ✅ Ansible playbooks for build & deploy
- ✅ GitHub Actions CI/CD workflows
- ✅ 7 different deployment pipelines
- ✅ Automated image builds and pushes

### Deployment Scripts
- ✅ `scripts/aks-deploy.sh` - AKS setup (10-15 min)
- ✅ `scripts/app-service-deploy.sh` - App Service setup (5 min)
- ✅ Manual deployment guides

### Documentation
- ✅ AZURE-DEPLOYMENT-OPTIONS.md - All deployment methods
- ✅ GITHUB-ACTIONS-SECRETS-SETUP.md - CI/CD setup
- ✅ ANSIBLE-SETUP.md - Automation guide
- ✅ Multiple quick-start guides

## 🚀 Quick Start

### 1. Choose Deployment Method

**Option A: Azure App Service (Recommended for Start)**
```bash
bash scripts/app-service-deploy.sh
```
- Easiest setup
- Built-in auto-scaling
- Free SSL/HTTPS
- ~5 minutes to deploy

**Option B: Azure Kubernetes Service (Production)**
```bash
bash scripts/aks-deploy.sh
```
- High availability
- Auto-scaling by CPU/Memory
- Production-ready
- ~10-15 minutes to deploy

**Option C: Manual in Azure Portal**
See: `AZURE-DEPLOYMENT-OPTIONS.md`

### 2. Setup GitHub Actions (Optional)

For automated deployments on every push:

1. Add GitHub secrets (see GITHUB-ACTIONS-SECRETS-SETUP.md):
   - AZURE_CREDENTIALS
   - AZURE_REGISTRY_USERNAME
   - AZURE_REGISTRY_PASSWORD
   - AZURE_APPSERVICE_NAME (for App Service)

2. Workflows are already configured:
   - `.github/workflows/deploy-app-service.yml`
   - `.github/workflows/deploy-aks.yml`
   - `.github/workflows/build-and-deploy.yml`

### 3. Use Ansible (Optional)

Build and push images automatically:
```bash
# Build Docker image
python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags build

# Push to registries
python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags push
```

## 📊 File Structure

```
.
├── src/                            # React source code
│   ├── Chatbot.tsx                # Main chatbot component
│   └── ...
├── k8s/                            # Kubernetes manifests
│   └── deployment.yaml            # AKS deployment config
├── scripts/                        # Deployment scripts
│   ├── aks-deploy.sh              # AKS setup script
│   └── app-service-deploy.sh      # App Service setup
├── ansible/                        # Automation playbooks
│   ├── main.yml                   # Main pipeline
│   ├── inventory.ini              # Configuration
│   └── README.md                  # Ansible docs
├── .github/workflows/             # GitHub Actions CI/CD
│   ├── deploy-aks.yml            # AKS deployment
│   ├── deploy-app-service.yml    # App Service deployment
│   └── ...more workflows
├── Dockerfile                      # Production image
├── docker-compose.yml             # Development setup
└── README.md                       # This file
```

## 🔄 Deployment Workflow

### 1. **Local Development**
```bash
npm run dev              # Start dev server with hot reload
docker-compose up -d    # Or run in Docker
```

### 2. **Build Production Image**
```bash
docker build -t react-chatbot:latest .
docker tag react-chatbot:latest shanumathew.azurecr.io/react-chatbot:latest
docker push shanumathew.azurecr.io/react-chatbot:latest
```

Or use Ansible:
```bash
python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml
```

### 3. **Deploy to Azure**

**App Service:**
```bash
bash scripts/app-service-deploy.sh
```

**AKS:**
```bash
bash scripts/aks-deploy.sh
```

### 4. **Access Your App**
- **App Service**: `https://react-chatbot-app.azurewebsites.net`
- **AKS**: Get LoadBalancer IP from `kubectl get svc`

## 💰 Cost Estimates (Monthly)

| Option | Compute | Registry | Total |
|--------|---------|----------|-------|
| **ACI** | $30-40 | $5 | ~$40-45 |
| **App Service (B2)** | $50 | $5 | ~$55 |
| **AKS (3 nodes)** | $150 | $5 | ~$155 |

## ✅ Verification

Run verification script:
```bash
python verify-ansible-config.py
```

Should show:
- ✓ Ansible installed
- ✓ All playbooks valid
- ✓ Configuration correct
- ✓ Docker installed

## 🆘 Troubleshooting

### Docker image not found
```bash
# Rebuild and push
docker build -t react-chatbot:latest .
docker tag react-chatbot:latest shanumathew.azurecr.io/react-chatbot:latest
docker push shanumathew.azurecr.io/react-chatbot:latest
```

### AKS pods not running
```bash
# Check pod status
kubectl get pods -n react-chatbot

# View logs
kubectl logs deployment/react-chatbot -n react-chatbot

# Describe pod for errors
kubectl describe pod <POD_NAME> -n react-chatbot
```

### App Service not responding
```bash
# View logs
az webapp log tail --resource-group react-chatbot-rg --name react-chatbot-app

# Check configuration
az webapp config appsettings list --resource-group react-chatbot-rg --name react-chatbot-app
```

## 📚 Documentation

- **AZURE-DEPLOYMENT-OPTIONS.md** - All deployment methods with step-by-step guides
- **GITHUB-ACTIONS-SECRETS-SETUP.md** - How to configure GitHub Actions
- **ANSIBLE-SETUP.md** - Ansible automation guide
- **ANSIBLE-CONFIG-STATUS.md** - Ansible configuration verification

## 🎯 Next Steps

1. **Deploy to Azure** (choose App Service or AKS)
2. **Test your app** at the provided URL
3. **Setup custom domain** (optional)
4. **Enable HTTPS** (built-in for App Service)
5. **Configure GitHub Actions** for automatic deployments
6. **Monitor and scale** using Azure Portal

## 🔐 Security Notes

- Never commit secrets or credentials
- Use GitHub secrets for CI/CD
- Rotate credentials regularly
- Use service principals for automation
- Enable HTTPS/SSL
- Use Azure Network Security Groups
- Keep Docker image updated

## 📞 Support

For issues:
1. Check logs in Azure Portal
2. Review GitHub Actions workflow runs
3. Verify secrets are configured
4. Check Docker image is in registry
5. Verify resource group and credentials

---

**Your app is ready for production!** 🚀

Start with App Service for the quickest deployment, then scale to AKS when needed.

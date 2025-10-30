# Docker + Minikube Terraform Configuration - Complete Guide

Terraform configuration for building Docker images and deploying to Minikube Kubernetes cluster.

---

## 📋 What This Does

1. **Builds Docker image** using Terraform
2. **Starts Minikube cluster** locally
3. **Deploys application** to Kubernetes
4. **Configures auto-scaling** (1-5 replicas)
5. **Sets up health checks** (liveness & readiness)
6. **Exposes service** via LoadBalancer
7. **Creates pod disruption budget** for high availability

---

## 🚀 Quick Start

### Prerequisites (one-time)
```bash
# Windows
choco install docker minikube kubernetes-cli terraform

# Mac
brew install docker minikube kubernetes-cli terraform

# Linux - follow official guides
```

### Deploy

**Windows (PowerShell):**
```bash
cd terraform
.\docker-minikube-deploy.bat
```

**Mac/Linux:**
```bash
cd terraform
bash docker-minikube-deploy.sh
```

---

## 📁 Files Included

- `docker-minikube-main.tf` - Main Terraform configuration
- `docker-minikube-variables.tf` - Variable definitions
- `docker-minikube.tfvars` - Default values
- `docker-minikube-deploy.sh` - Deployment script (Mac/Linux)
- `docker-minikube-deploy.bat` - Deployment script (Windows)

---

## 🔧 Manual Deployment

If script fails:

```bash
# 1. Start Minikube
minikube start --cpus=4 --memory=4096

# 2. Configure Docker (PowerShell on Windows)
minikube docker-env | Invoke-Expression

# Or (Mac/Linux):
eval $(minikube docker-env)

# 3. Enable addons
minikube addons enable registry
minikube addons enable metrics-server

# 4. Navigate to terraform
cd terraform

# 5. Initialize
terraform init

# 6. Plan
terraform plan -var-file=docker-minikube.tfvars

# 7. Apply
terraform apply -var-file=docker-minikube.tfvars

# 8. Expose service
minikube tunnel

# 9. Access
http://localhost
```

---

## 📊 Configuration Options

Edit `docker-minikube.tfvars`:

```hcl
# Number of initial replicas
replicas = 2

# Auto-scaling range
min_replicas = 1
max_replicas = 5

# Resource limits
cpu_request = "250m"
cpu_limit = "500m"
memory_request = "256Mi"
memory_limit = "512Mi"

# Autoscaling thresholds
cpu_target_utilization = 70
memory_target_utilization = 80

# Environment
environment = "production"
```

---

## ✅ What Gets Created

✅ Docker image built and tagged  
✅ Kubernetes namespace  
✅ Deployment (2 replicas)  
✅ Service (LoadBalancer)  
✅ Horizontal Pod Autoscaler (1-5 replicas)  
✅ Pod Disruption Budget  
✅ Health checks (liveness & readiness)  
✅ ConfigMap for environment variables  

---

## 📈 Check Deployment Status

```bash
# Pod status
kubectl get pods -n react-chatbot

# Services
kubectl get svc -n react-chatbot

# Deployment
kubectl get deployment -n react-chatbot

# Watch logs
kubectl logs -f deployment/react-chatbot -n react-chatbot

# Watch pods
kubectl get pods -n react-chatbot --watch
```

---

## 🔄 Update Application

After code changes:

```bash
# 1. Rebuild and redeploy
cd terraform
terraform apply -var-file=docker-minikube.tfvars

# Or manually:
docker build -t react-chatbot:latest ..
kubectl rollout restart deployment/react-chatbot -n react-chatbot
```

---

## 📊 Architecture

```
┌──────────────────────────────────────┐
│    Terraform                         │
├──────────────────────────────────────┤
│                                      │
│  Docker Provider                     │
│  ├─ Build Docker image              │
│  └─ Tag: react-chatbot:latest       │
│                                      │
│  Kubernetes Provider                 │
│  ├─ Namespace: react-chatbot        │
│  ├─ Deployment (2 replicas)         │
│  │  └─ Pods running Docker image    │
│  ├─ Service (LoadBalancer)          │
│  │  └─ Exposes on port 80           │
│  ├─ HPA (auto-scaler)               │
│  │  └─ 1-5 replicas based on load   │
│  └─ PDB (pod disruption budget)     │
│                                      │
└──────────────────────────────────────┘
         │
         ▼
    ┌─────────────┐
    │   Minikube  │
    │ Kubernetes  │
    │  Cluster    │
    └─────────────┘
```

---

## 🛠️ Terraform Commands

```bash
# Initialize
terraform init

# Format
terraform fmt

# Validate
terraform validate

# Plan
terraform plan -var-file=docker-minikube.tfvars

# Apply
terraform apply -var-file=docker-minikube.tfvars

# Destroy
terraform destroy -var-file=docker-minikube.tfvars

# Show state
terraform show

# List resources
terraform state list
```

---

## 🆘 Troubleshooting

### "Cannot connect to Docker daemon"
```bash
# Ensure Docker is running
minikube docker-env  # Check environment
eval $(minikube docker-env)  # Mac/Linux
# Or PowerShell: minikube docker-env | Invoke-Expression
```

### "Pods not starting"
```bash
# Check what's wrong
kubectl describe pod <POD_NAME> -n react-chatbot

# Check logs
kubectl logs <POD_NAME> -n react-chatbot
```

### "Terraform state conflicts"
```bash
# Remove lock if stuck
terraform force-unlock LOCK_ID

# Or reset
rm -rf .terraform
terraform init
```

### "Out of memory"
```bash
# Increase Minikube memory
minikube start --memory=6144  # 6GB

# Or edit config
minikube config set memory 6144
```

---

## 💾 Resource Requirements

- **RAM**: 4+ GB (Minikube uses 4GB)
- **CPU**: 4+ cores
- **Disk**: 50+ GB
- **Docker**: Running
- **Minikube**: Started

---

## 🎯 Deployment Workflow

1. **Code changes** → Edit source files
2. **Commit** → `git add . && git commit`
3. **Redeploy** → `terraform apply -var-file=docker-minikube.tfvars`
4. **Verify** → `kubectl get pods -n react-chatbot`
5. **Test** → Access `http://localhost`

---

## ✨ Key Features

✅ **Automated Docker build** via Terraform  
✅ **Kubernetes deployment** management  
✅ **Auto-scaling** based on CPU/Memory  
✅ **Health checks** for reliability  
✅ **Service exposure** via LoadBalancer  
✅ **Pod disruption budget** for availability  
✅ **Rolling updates** configured  
✅ **Resource limits** enforced  

---

## 📝 Files Configuration

### docker-minikube.tfvars
- Docker image settings
- Kubernetes deployment settings
- Resource limits
- Autoscaling parameters
- Environment variables

### docker-minikube-main.tf
- Docker image build
- Kubernetes deployment
- Service configuration
- HPA setup
- Pod disruption budget

### docker-minikube-variables.tf
- Input variable definitions
- Validation rules
- Default values

---

## 🚀 Status

✅ **Ready to deploy!**

Run the deployment script:
- **Windows**: `terraform\docker-minikube-deploy.bat`
- **Mac/Linux**: `bash terraform/docker-minikube-deploy.sh`

Your app will be running in 5-10 minutes!

---

## 📞 Support

Check logs in Minikube Dashboard:
```bash
minikube dashboard
```

Or via kubectl:
```bash
kubectl logs -f deployment/react-chatbot -n react-chatbot
kubectl describe pod <POD_NAME> -n react-chatbot
```

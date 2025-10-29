# Minikube Configuration - Complete Setup

Your React Chatbot is fully configured for local Kubernetes development using Minikube.

---

## 📋 What's Configured

✅ **MINIKUBE-SETUP.md** - Detailed setup guide  
✅ **MINIKUBE-QUICK-START.md** - Quick reference  
✅ **scripts/setup-minikube.sh** - Auto-setup script (Mac/Linux)  
✅ **scripts/setup-minikube.bat** - Auto-setup script (Windows)  
✅ **terraform/minikube-main.tf** - Terraform deployment  
✅ **terraform/minikube-variables.tf** - Terraform variables  
✅ **terraform/minikube.tfvars** - Terraform configuration  
✅ **terraform/minikube-deploy.sh** - Terraform deploy (Mac/Linux)  
✅ **terraform/minikube-deploy.bat** - Terraform deploy (Windows)  

---

## 🚀 Quick Start (5 minutes)

### Option 1: Automatic Setup Script

**Windows:**
```bash
cd scripts
.\setup-minikube.bat
```

**Mac/Linux:**
```bash
bash scripts/setup-minikube.sh
```

### Option 2: Terraform Deployment

**Windows:**
```bash
cd terraform
minikube-deploy.bat
```

**Mac/Linux:**
```bash
cd terraform
bash minikube-deploy.sh
```

### Option 3: Manual Steps

```bash
# 1. Start Minikube
minikube start --cpus=4 --memory=4096

# 2. Configure Docker (PowerShell on Windows)
minikube docker-env | Invoke-Expression

# Or (Mac/Linux):
eval $(minikube docker-env)

# 3. Build image
docker build -t react-chatbot:latest .

# 4. Deploy
kubectl create namespace react-chatbot
kubectl apply -f k8s/deployment.yaml -n react-chatbot

# 5. Expose service
minikube tunnel

# 6. Access
http://localhost
```

---

## 📊 What Gets Deployed

After deployment, you'll have:

- ✅ Local Kubernetes cluster (Minikube)
- ✅ React Chatbot deployment (2 replicas)
- ✅ Auto-scaling enabled (1-5 replicas based on CPU/Memory)
- ✅ Load balancer service
- ✅ Health checks (liveness & readiness)
- ✅ Resource limits configured
- ✅ Metrics server enabled
- ✅ Dashboard available

---

## 🔍 Check Status

```bash
# Cluster status
minikube status

# Pod status
kubectl get pods -n react-chatbot

# Services
kubectl get svc -n react-chatbot

# Watch pods
kubectl get pods -n react-chatbot --watch

# Logs
kubectl logs -f deployment/react-chatbot -n react-chatbot

# Describe pod
kubectl describe pod <POD_NAME> -n react-chatbot
```

---

## 📈 Dashboard

```bash
minikube dashboard
```

Opens web UI showing:
- Deployments
- Pods status
- Services
- Resource usage graphs
- Real-time monitoring
- Pod logs
- Events

---

## 🔄 Updating Your App

After making code changes:

```bash
# 1. Rebuild image
docker build -t react-chatbot:latest .

# 2. Trigger rollout
kubectl rollout restart deployment/react-chatbot -n react-chatbot

# 3. Watch restart
kubectl get pods -n react-chatbot --watch

# 4. View logs
kubectl logs -f deployment/react-chatbot -n react-chatbot
```

---

## 📦 Useful Commands

```bash
# Minikube
minikube start
minikube stop
minikube restart
minikube delete
minikube tunnel
minikube dashboard
minikube logs
minikube ip
minikube ssh

# Kubectl
kubectl get pods -n react-chatbot
kubectl get svc -n react-chatbot
kubectl logs <POD> -n react-chatbot
kubectl exec -it <POD> -n react-chatbot -- /bin/sh
kubectl port-forward svc/react-chatbot-service 3000:80 -n react-chatbot
kubectl describe pod <POD> -n react-chatbot
kubectl scale deployment react-chatbot --replicas=3 -n react-chatbot

# Terraform
terraform init
terraform plan -var-file=minikube.tfvars
terraform apply -var-file=minikube.tfvars
terraform destroy -var-file=minikube.tfvars
```

---

## 🛠️ System Requirements

- **RAM**: 4+ GB
- **CPU**: 4+ cores
- **Disk**: 50+ GB
- **Docker Desktop** (Windows/Mac) or Docker (Linux)
- **Minikube** installed
- **kubectl** installed

---

## 🔄 Development Workflow

1. **Edit code** in your editor
2. **Rebuild Docker image** after changes
3. **Trigger rollout** in Minikube
4. **View logs** to verify
5. **Test app** at `http://localhost`
6. **Commit** and push when ready

---

## 🚨 Common Issues & Solutions

### "Cannot connect to Docker daemon"
- Ensure Docker Desktop is running
- Or start Docker service on Linux

### "Pods not starting"
```bash
# Check what's wrong
kubectl describe pod <POD_NAME> -n react-chatbot

# Check image exists
docker images | grep react-chatbot

# Check logs
kubectl logs <POD_NAME> -n react-chatbot
```

### "Minikube out of memory"
```bash
minikube start --memory=6144  # Increase to 6GB
```

### "Cannot access app at localhost"
```bash
# Keep tunnel running
minikube tunnel

# In another terminal, access:
http://localhost
```

---

## 📊 Architecture

```
┌─────────────────────────────────────────┐
│         Your Computer (Minikube)        │
├─────────────────────────────────────────┤
│  Kubernetes Cluster                     │
│  ┌──────────────────────────────────┐   │
│  │  Namespace: react-chatbot        │   │
│  ├──────────────────────────────────┤   │
│  │  Deployment (2 replicas)         │   │
│  │  ├─ Pod 1: react-chatbot         │   │
│  │  └─ Pod 2: react-chatbot         │   │
│  │                                  │   │
│  │  Service (LoadBalancer)          │   │
│  │  └─ Exposes on port 80           │   │
│  │                                  │   │
│  │  HPA (Auto-scaler)               │   │
│  │  └─ 1-5 replicas based on CPU    │   │
│  └──────────────────────────────────┘   │
│                                         │
│  Access: http://localhost               │
└─────────────────────────────────────────┘
```

---

## ✅ Deployment Checklist

- [ ] Install Docker Desktop
- [ ] Install Minikube
- [ ] Install kubectl
- [ ] Run setup script or manual steps
- [ ] Run `minikube tunnel` in separate terminal
- [ ] Access app at `http://localhost`
- [ ] Open dashboard with `minikube dashboard`
- [ ] Check pods: `kubectl get pods -n react-chatbot`
- [ ] View logs: `kubectl logs -f deployment/react-chatbot -n react-chatbot`
- [ ] Test app functionality

---

## 🎯 Next Steps

1. **Install prerequisites** (Docker, Minikube, kubectl)
2. **Run setup script** (automatic)
   - Or follow manual steps
3. **Run `minikube tunnel`** in separate terminal
4. **Access app** at `http://localhost`
5. **Open dashboard** with `minikube dashboard`
6. **View logs** to monitor

---

## 📚 Detailed Guides

- `MINIKUBE-SETUP.md` - Complete setup instructions
- `MINIKUBE-QUICK-START.md` - Quick reference
- `terraform/RENDER-TERRAFORM.md` - Terraform guide (if using TF)

---

## 🚀 Status

✅ **Minikube is fully configured!**

Everything is set up and ready. Just run the setup script or follow manual steps to deploy your React Chatbot to local Kubernetes.

**5 minutes to local Kubernetes!** ⚡

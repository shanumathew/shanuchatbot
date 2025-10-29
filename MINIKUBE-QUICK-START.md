# Minikube - Quick Start Guide

Fast local Kubernetes testing for your React Chatbot.

---

## ⚡ 5-Minute Quick Start

### Prerequisites (one-time setup)
```bash
# Windows (Chocolatey)
choco install minikube kubectl docker-cli

# Mac
brew install minikube kubectl docker

# Linux
# Follow: https://minikube.sigs.k8s.io/docs/start/
```

### Deploy

**Windows (PowerShell):**
```bash
cd scripts
.\setup-minikube.bat
```

**Mac/Linux:**
```bash
bash scripts/setup-minikube.sh
```

---

## 🚀 Manual Steps (if script fails)

```bash
# 1. Start Minikube
minikube start --cpus=4 --memory=4096

# 2. Configure Docker (Windows PowerShell)
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

## 📊 Check Status

```bash
# Minikube status
minikube status

# Pods
kubectl get pods -n react-chatbot

# Services
kubectl get svc -n react-chatbot

# Logs
kubectl logs -f deployment/react-chatbot -n react-chatbot
```

---

## 📈 Dashboard

```bash
minikube dashboard
```

Opens web UI showing:
- Pods, deployments, services
- Resource usage
- Logs
- Real-time monitoring

---

## 🛑 Stop/Delete

```bash
# Stop (keeps data)
minikube stop

# Delete everything
minikube delete
```

---

## ✅ What's Included

✅ Local Kubernetes cluster  
✅ Docker integration  
✅ Metrics monitoring  
✅ Web dashboard  
✅ Image registry  
✅ Auto-scaling configured  
✅ Health checks  

---

## 💾 System Requirements

- 4+ GB RAM
- 4+ CPU cores
- 50 GB disk space
- Docker Desktop (Windows/Mac)

---

## 🎯 Next Steps

1. Install prerequisites
2. Run setup script
3. Run `minikube tunnel` in new terminal
4. Access app at `http://localhost`
5. View dashboard: `minikube dashboard`

**Kubernetes locally in minutes!** 🚀

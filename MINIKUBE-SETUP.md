# Minikube Configuration for React Chatbot

Minikube allows you to run Kubernetes locally for testing and development.

---

## 📋 Prerequisites

### Windows
```bash
# Install Docker Desktop (includes Docker)
# Download: https://www.docker.com/products/docker-desktop

# Install Minikube
choco install minikube

# Or download from: https://github.com/kubernetes/minikube/releases

# Install kubectl
choco install kubernetes-cli

# Verify
minikube version
kubectl version --client
```

### Mac
```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Minikube
brew install minikube

# Install kubectl
brew install kubectl

# Verify
minikube version
kubectl version --client
```

### Linux
```bash
# Install Docker first
sudo apt-get update
sudo apt-get install docker.io -y

# Install Minikube
curl -Lo minikube https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify
minikube version
kubectl version --client
```

---

## 🚀 Quick Start

### Step 1: Start Minikube
```bash
# Start cluster (takes 1-2 minutes first time)
minikube start

# Verify
minikube status

# Check nodes
kubectl get nodes
```

### Step 2: Enable Required Addons
```bash
# Enable registry addon (for local images)
minikube addons enable registry

# Enable metrics server (for monitoring)
minikube addons enable metrics-server

# Enable dashboard (optional, but useful)
minikube addons enable dashboard

# List all addons
minikube addons list
```

### Step 3: Configure Docker to Use Minikube
```bash
# Windows (PowerShell)
minikube docker-env | Invoke-Expression

# Mac/Linux
eval $(minikube docker-env)

# Verify
docker ps
```

### Step 4: Build Image in Minikube
```bash
# Build Docker image (uses Minikube's Docker)
docker build -t react-chatbot:latest .

# Verify image exists
docker images | grep react-chatbot
```

### Step 5: Deploy to Minikube
```bash
# Create namespace
kubectl create namespace react-chatbot

# Apply Kubernetes manifests
kubectl apply -f k8s/deployment.yaml -n react-chatbot

# Verify deployment
kubectl get pods -n react-chatbot
kubectl get svc -n react-chatbot
```

### Step 6: Access Your App
```bash
# Get service URL
minikube service react-chatbot-service -n react-chatbot

# Or tunnel (keep running)
minikube tunnel

# Then access: http://localhost
```

---

## 🔧 Configuration Files

### Create minikube-config.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: chatbot-config
  namespace: react-chatbot
data:
  NODE_ENV: "production"
  PORT: "3000"
```

### Create minikube-secrets.yaml
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: chatbot-secrets
  namespace: react-chatbot
type: Opaque
stringData:
  VITE_API_KEY: "your-gemini-api-key"
```

---

## 📊 Useful Minikube Commands

```bash
# Start/Stop
minikube start
minikube stop
minikube restart
minikube delete

# Get information
minikube status
minikube ip
minikube version
minikube config view

# Dashboard
minikube dashboard

# Logs
minikube logs
minikube logs --follow

# SSH into Minikube
minikube ssh

# Tunnel (expose services)
minikube tunnel

# Mount local folder
minikube mount /path/to/local:/path/in/minikube

# Upgrade
minikube update-check
```

---

## 🐳 Docker Integration

### Check Minikube Docker Environment
```bash
# Windows
minikube docker-env

# Mac/Linux
minikube docker-env
```

### Pull Images into Minikube
```bash
# Method 1: Build locally (recommended)
eval $(minikube docker-env)
docker build -t react-chatbot:latest .

# Method 2: Pull from registry
docker pull nginx:latest
```

---

## 📦 Kubectl Commands

```bash
# Deployments
kubectl get deployments -n react-chatbot
kubectl describe deployment react-chatbot -n react-chatbot
kubectl logs deployment/react-chatbot -n react-chatbot -f

# Pods
kubectl get pods -n react-chatbot
kubectl describe pod <POD_NAME> -n react-chatbot
kubectl logs <POD_NAME> -n react-chatbot

# Services
kubectl get svc -n react-chatbot
kubectl describe svc react-chatbot-service -n react-chatbot

# Port forward
kubectl port-forward svc/react-chatbot-service 3000:80 -n react-chatbot

# Execute command in pod
kubectl exec -it <POD_NAME> -n react-chatbot -- /bin/sh

# Delete resources
kubectl delete pod <POD_NAME> -n react-chatbot
kubectl delete namespace react-chatbot
```

---

## 🔄 Development Workflow

### Local Testing Loop
```bash
# 1. Edit code
# 2. Build image
docker build -t react-chatbot:latest .

# 3. Check image
docker images | grep react-chatbot

# 4. Update deployment (forces restart)
kubectl rollout restart deployment/react-chatbot -n react-chatbot

# 5. Check status
kubectl get pods -n react-chatbot

# 6. View logs
kubectl logs -f deployment/react-chatbot -n react-chatbot

# 7. Test
curl http://localhost
```

---

## 🎯 Example: Complete Deployment

```bash
# 1. Start Minikube
minikube start

# 2. Configure Docker
eval $(minikube docker-env)  # Mac/Linux
# OR
minikube docker-env | Invoke-Expression  # Windows

# 3. Build image
docker build -t react-chatbot:latest .

# 4. Create namespace
kubectl create namespace react-chatbot

# 5. Deploy
kubectl apply -f k8s/deployment.yaml -n react-chatbot

# 6. Wait for pods
kubectl get pods -n react-chatbot --watch

# 7. Access service
minikube service react-chatbot-service -n react-chatbot
```

---

## 📊 Monitor Dashboard

```bash
# Open Kubernetes Dashboard
minikube dashboard

# This opens a web UI showing:
# - Pods status
# - Deployments
# - Services
# - Resource usage
# - Logs
```

---

## 🔍 Troubleshooting

### "Cannot connect to Docker daemon"
```bash
# Ensure Docker Desktop is running (Windows/Mac)
# Or start Docker service (Linux):
sudo systemctl start docker
```

### "Pods not starting"
```bash
# Check pod events
kubectl describe pod <POD_NAME> -n react-chatbot

# Check image exists
docker images | grep react-chatbot

# Check logs
kubectl logs <POD_NAME> -n react-chatbot
```

### "Service URL not accessible"
```bash
# Use tunnel
minikube tunnel

# Keep terminal open, then access in another terminal
```

### "Out of memory"
```bash
# Increase Minikube memory
minikube start --memory=4096

# Check current settings
minikube config view
```

---

## 💾 Resource Settings

```bash
# Start with custom resources
minikube start \
  --cpus=4 \
  --memory=4096 \
  --disk-size=50g

# Or edit config
minikube config set memory 4096
minikube config set cpus 4
minikube config set disk-size 50gb
```

---

## 🚀 Clean Up

```bash
# Stop Minikube (keeps data)
minikube stop

# Delete everything
minikube delete

# Verify deleted
minikube status
```

---

## ✅ Verification

Check if everything works:
```bash
# 1. Check Minikube
minikube status

# 2. Check nodes
kubectl get nodes

# 3. Check namespaces
kubectl get namespaces

# 4. Check pods
kubectl get pods -n react-chatbot

# 5. Check services
kubectl get svc -n react-chatbot

# 6. Test connectivity
kubectl run test-pod --image=nginx -n react-chatbot
kubectl exec test-pod -n react-chatbot -- curl localhost:3000
```

---

## 📚 Quick Reference

| Command | Purpose |
|---------|---------|
| `minikube start` | Start cluster |
| `minikube stop` | Stop cluster |
| `minikube status` | Check status |
| `minikube dashboard` | Open UI |
| `kubectl apply -f` | Deploy |
| `kubectl get pods` | List pods |
| `kubectl logs -f` | View logs |
| `minikube tunnel` | Expose services |

---

## 🎯 Next Steps

1. Install prerequisites (Docker, Minikube, kubectl)
2. Start Minikube: `minikube start`
3. Configure Docker: `eval $(minikube docker-env)`
4. Build image: `docker build -t react-chatbot:latest .`
5. Deploy: `kubectl apply -f k8s/deployment.yaml -n react-chatbot`
6. Access: `minikube service react-chatbot-service -n react-chatbot`

**Your local Kubernetes cluster is ready!** 🚀

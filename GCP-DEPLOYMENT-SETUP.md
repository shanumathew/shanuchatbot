# Google Cloud Platform - Deployment Setup

Your gcloud CLI is installed and you're logged in as `shanumathew32@gmail.com`.

**Project:** `shanuchatbot` (ID: 975755324949)

---

## ⚠️ **NEXT STEP: Enable Billing**

Your project needs billing enabled to use Google Cloud services.

### **Enable Billing:**

1. Go to: https://console.cloud.google.com/billing
2. Click "Link Billing Account"
3. Create or select a billing account
4. Link it to the `shanuchatbot` project
5. Or use free credits (if new account)

**Or via CLI:**
```bash
gcloud billing accounts list
gcloud billing projects link shanuchatbot --billing-account=BILLING_ACCOUNT_ID
```

---

## ✅ **After Billing is Enabled**

Run these commands to enable required APIs:

```bash
# Enable Container Registry
gcloud services enable containerregistry.googleapis.com

# Enable Cloud Run
gcloud services enable run.googleapis.com

# Enable Kubernetes Engine (GKE)
gcloud services enable container.googleapis.com

# Enable Artifact Registry
gcloud services enable artifactregistry.googleapis.com
```

---

## 🚀 **Then Deploy Your App**

### **Option 1: Cloud Run (Easiest)**
```bash
# Build Docker image
docker build -t react-chatbot:latest .

# Tag for GCP
docker tag react-chatbot:latest gcr.io/shanuchatbot/react-chatbot:latest

# Authenticate Docker
gcloud auth configure-docker

# Push image
docker push gcr.io/shanuchatbot/react-chatbot:latest

# Deploy to Cloud Run
gcloud run deploy react-chatbot \
  --image gcr.io/shanuchatbot/react-chatbot:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 3000 \
  --memory 512Mi
```

Get your URL:
```bash
gcloud run services describe react-chatbot --region us-central1
```

---

### **Option 2: Google Kubernetes Engine (GKE)**
```bash
# Create cluster
gcloud container clusters create react-chatbot-cluster \
  --zone us-central1-a \
  --num-nodes 3 \
  --machine-type n1-standard-1 \
  --enable-autoscaling \
  --min-nodes 1 \
  --max-nodes 5

# Get credentials
gcloud container clusters get-credentials react-chatbot-cluster --zone us-central1-a

# Deploy
kubectl apply -f k8s/deployment.yaml

# Expose service
kubectl expose deployment react-chatbot --type=LoadBalancer --port=80 --target-port=3000

# Get IP
kubectl get service react-chatbot
```

---

## 📝 **Current Status**

✅ gcloud CLI installed  
✅ Logged in as: `shanumathew32@gmail.com`  
✅ Project set: `shanuchatbot`  
⏳ **PENDING:** Enable billing  
⏳ **PENDING:** Enable APIs  
⏳ **PENDING:** Deploy app  

---

## 🎯 **Next Steps**

1. **Enable Billing** (link billing account to project)
2. **Enable APIs** (run commands above)
3. **Build & Push Docker image**
4. **Deploy to Cloud Run or GKE**

---

## 💰 **Pricing**

**Cloud Run:**
- Free tier: 2 million requests/month
- $0.20 per 1 million requests
- $0.00001667 per vCPU-second

**GKE:**
- Cluster management: Free
- Nodes: $30-50/month each

---

## 📞 **Useful Commands**

```bash
# Check current project
gcloud config list

# Set region
gcloud config set compute/region us-central1

# List services
gcloud run services list

# View logs
gcloud run services describe react-chatbot --region us-central1

# Delete service
gcloud run services delete react-chatbot --region us-central1

# List clusters
gcloud container clusters list

# Delete cluster
gcloud container clusters delete react-chatbot-cluster --zone us-central1-a
```

---

**Go to https://console.cloud.google.com/billing and enable billing for the project!**

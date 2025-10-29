# Cloud Deployment Guide

## Deployment Overview

Your React Chatbot can be deployed to multiple cloud platforms. This guide covers:

1. **AWS (EC2, ECS, AppRunner)**
2. **Google Cloud (Compute Engine, Cloud Run)**
3. **Azure (Container Instances, App Service)**
4. **DigitalOcean (Droplets, App Platform)**
5. **Heroku**
6. **Docker Hub Registry**

---

## 1. AWS Deployment

### Option A: AWS AppRunner (Easiest)

```bash
# Push to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
docker tag react-chatbot:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/react-chatbot:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/react-chatbot:latest

# Create AppRunner service via AWS Console
# - Source: ECR
# - Image URI: <account-id>.dkr.ecr.us-east-1.amazonaws.com/react-chatbot:latest
# - Port: 3000
```

### Option B: AWS ECS

```bash
# Create task definition
aws ecs register-task-definition \
  --family react-chatbot \
  --network-mode awsvpc \
  --requires-compatibilities FARGATE \
  --cpu 256 \
  --memory 512 \
  --container-definitions '[{
    "name": "chatbot",
    "image": "<account-id>.dkr.ecr.us-east-1.amazonaws.com/react-chatbot:latest",
    "portMappings": [{"containerPort": 3000}]
  }]'

# Create ECS service
aws ecs create-service \
  --cluster my-cluster \
  --service-name react-chatbot \
  --task-definition react-chatbot:1 \
  --launch-type FARGATE
```

### Option C: AWS EC2

```bash
# SSH into EC2 instance
ssh -i key.pem ec2-user@instance-ip

# Install Docker
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# Pull and run image
docker pull <account-id>.dkr.ecr.us-east-1.amazonaws.com/react-chatbot:latest
docker-compose -f docker-compose.prod.yml up -d
```

---

## 2. Google Cloud Deployment

### Option A: Cloud Run (Recommended)

```bash
# Build and push to Artifact Registry
gcloud builds submit --tag gcr.io/PROJECT-ID/react-chatbot

# Deploy to Cloud Run
gcloud run deploy react-chatbot \
  --image gcr.io/PROJECT-ID/react-chatbot \
  --platform managed \
  --region us-central1 \
  --port 3000 \
  --memory 512Mi \
  --cpu 1 \
  --allow-unauthenticated
```

### Option B: Compute Engine

```bash
# Create VM instance
gcloud compute instances create react-chatbot \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --zone=us-central1-a

# SSH and setup
gcloud compute ssh react-chatbot --zone=us-central1-a

# Install Docker and run
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
docker-compose -f docker-compose.prod.yml up -d
```

### Option C: GKE (Kubernetes)

```bash
# Create cluster
gcloud container clusters create chatbot-cluster \
  --zone us-central1-a \
  --num-nodes 3

# Build and push image
gcloud builds submit --tag gcr.io/PROJECT-ID/react-chatbot

# Deploy
kubectl apply -f k8s-deployment.yaml
```

---

## 3. Azure Deployment

### Option A: Azure Container Instances

```bash
# Push to Azure Container Registry
az login
az acr build --registry myregistry --image react-chatbot:latest .

# Deploy
az container create \
  --resource-group mygroup \
  --name react-chatbot \
  --image myregistry.azurecr.io/react-chatbot:latest \
  --cpu 1 \
  --memory 1 \
  --port 3000
```

### Option B: Azure App Service

```bash
# Create App Service
az appservice plan create \
  --name myAppServicePlan \
  --resource-group mygroup \
  --sku B2 \
  --is-linux

az webapp create \
  --resource-group mygroup \
  --plan myAppServicePlan \
  --name react-chatbot \
  --deployment-container-image-name myregistry.azurecr.io/react-chatbot:latest
```

---

## 4. DigitalOcean Deployment

### Option A: DigitalOcean App Platform

```bash
# Create app.yaml
cat > app.yaml << EOF
name: react-chatbot
services:
- name: chatbot
  github:
    repo: your-username/your-repo
    branch: main
  build_command: docker build -t react-chatbot .
  http_port: 3000
  health_check:
    http_path: /
EOF

# Deploy
doctl apps create --spec app.yaml
```

### Option B: DigitalOcean Droplet

```bash
# SSH to Droplet
ssh root@droplet-ip

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Clone repo and deploy
git clone your-repo
cd chatbot-devops
docker-compose -f docker-compose.prod.yml up -d
```

---

## 5. Heroku Deployment

```bash
# Install Heroku CLI
npm install -g heroku

# Login
heroku login

# Create app
heroku create your-chatbot

# Create heroku.yml
cat > heroku.yml << EOF
build:
  docker:
    web: Dockerfile
run:
  web: serve -s dist -l 3000
EOF

# Deploy
git push heroku main

# View logs
heroku logs --tail
```

---

## 6. Docker Hub Registry

### Push to Docker Hub

```bash
# Login
docker login

# Build and tag
docker build -t your-username/react-chatbot:latest .

# Push
docker push your-username/react-chatbot:latest

# Run from any machine
docker run -d -p 3000:3000 your-username/react-chatbot:latest
```

### Create Docker Hub Automated Build

1. Connect GitHub account to Docker Hub
2. Select repository
3. Configure automated builds
4. Set build rules (e.g., main branch → latest tag)

---

## Environment-Specific Configurations

### Production (.env.prod)

```env
NODE_ENV=production
DEBUG=false
LOG_LEVEL=error
ENABLE_MONITORING=true
ENABLE_ANALYTICS=true
```

### Staging (.env.staging)

```env
NODE_ENV=staging
DEBUG=true
LOG_LEVEL=warn
ENABLE_MONITORING=true
ENABLE_ANALYTICS=true
```

### Development (.env.dev)

```env
NODE_ENV=development
DEBUG=true
LOG_LEVEL=debug
ENABLE_MONITORING=false
ENABLE_ANALYTICS=false
```

---

## CI/CD Pipeline Setup

### GitHub Actions Example

```yaml
name: Build and Deploy

on:
  push:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Build Docker image
        run: docker build -t react-chatbot:${{ github.sha }} .
      
      - name: Push to registry
        run: |
          docker tag react-chatbot:${{ github.sha }} myregistry/react-chatbot:latest
          docker push myregistry/react-chatbot:latest
      
      - name: Deploy to production
        run: |
          # Deploy command (e.g., kubectl apply, docker-compose pull, etc.)
          kubectl set image deployment/chatbot chatbot=myregistry/react-chatbot:latest
```

### GitLab CI Example

```yaml
stages:
  - build
  - push
  - deploy

build:
  stage: build
  image: docker:latest
  script:
    - docker build -t react-chatbot:latest .

push:
  stage: push
  image: docker:latest
  script:
    - docker tag react-chatbot:latest registry.gitlab.com/user/react-chatbot:latest
    - docker push registry.gitlab.com/user/react-chatbot:latest

deploy:
  stage: deploy
  image: bitnami/kubectl:latest
  script:
    - kubectl set image deployment/chatbot chatbot=registry.gitlab.com/user/react-chatbot:latest
```

---

## DNS and Domain Configuration

### Point Domain to Deployment

**For AWS:**
```
CNAME: your-domain.com → your-app.us-east-1.elb.amazonaws.com
```

**For Google Cloud Run:**
```
CNAME: your-domain.com → ghs.googleusercontent.com
```

**For DigitalOcean:**
```
A Record: your-domain.com → droplet-ip
```

### SSL/TLS Certificates

**Option 1: Let's Encrypt (Free)**
```bash
docker run --rm --name certbot \
  -v /etc/letsencrypt:/etc/letsencrypt \
  -v /var/lib/letsencrypt:/var/lib/letsencrypt \
  certbot/certbot certonly --webroot \
  -w /app/dist \
  -d your-domain.com
```

**Option 2: Cloud Provider SSL**
- AWS Certificate Manager
- Google Cloud SSL
- Azure App Service Certificates

---

## Monitoring and Logging

### CloudWatch (AWS)

```bash
# View logs
aws logs tail /aws/ecs/react-chatbot --follow
```

### Cloud Logging (Google Cloud)

```bash
# View logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=react-chatbot"
```

### Azure Monitor

Access via Azure Portal → Application Insights

---

## Scaling Configuration

### Horizontal Scaling

```yaml
# kubernetes HPA (already in k8s-deployment.yaml)
autoscaling:
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 70
```

### Vertical Scaling

Increase CPU/Memory in deployment configuration

---

## Cost Optimization

1. **Use Alpine Linux** (already implemented)
2. **Enable auto-scaling** (scale down when not needed)
3. **Use spot/preemptible instances** for non-critical workloads
4. **Cache static assets** (CDN configuration)
5. **Monitor resource usage** and adjust limits

---

## Deployment Checklist

- [ ] Build Docker image successfully
- [ ] Push to registry
- [ ] Configure environment variables
- [ ] Test health checks
- [ ] Setup monitoring/logging
- [ ] Configure SSL/TLS
- [ ] Setup backups
- [ ] Configure auto-scaling
- [ ] Monitor first deployment
- [ ] Setup CI/CD pipeline

---

For platform-specific details, visit official documentation:
- [AWS Documentation](https://docs.aws.amazon.com/)
- [Google Cloud Documentation](https://cloud.google.com/docs)
- [Azure Documentation](https://docs.microsoft.com/azure/)
- [DigitalOcean Documentation](https://docs.digitalocean.com/)
- [Heroku Documentation](https://devcenter.heroku.com/)

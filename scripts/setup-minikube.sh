#!/bin/bash
# Minikube Setup and Deployment Script
# Automates local Kubernetes cluster setup and deployment

set -e

echo "=========================================="
echo "Minikube Setup for React Chatbot"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

if ! command -v minikube &> /dev/null; then
    echo -e "${RED}Minikube not installed${NC}"
    echo "Install from: https://github.com/kubernetes/minikube/releases"
    exit 1
fi
echo -e "${GREEN}✓ Minikube installed${NC}"

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}kubectl not installed${NC}"
    echo "Install from: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi
echo -e "${GREEN}✓ kubectl installed${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker not installed${NC}"
    echo "Install Docker Desktop from: https://www.docker.com/products/docker-desktop"
    exit 1
fi
echo -e "${GREEN}✓ Docker installed${NC}"

# Start Minikube
echo -e "${BLUE}Starting Minikube...${NC}"
minikube start --cpus=4 --memory=4096 --disk-size=50gb

echo -e "${GREEN}✓ Minikube started${NC}"

# Enable addons
echo -e "${BLUE}Enabling addons...${NC}"
minikube addons enable registry
minikube addons enable metrics-server
minikube addons enable dashboard
echo -e "${GREEN}✓ Addons enabled${NC}"

# Configure Docker
echo -e "${BLUE}Configuring Docker...${NC}"
eval $(minikube docker-env)
echo -e "${GREEN}✓ Docker configured${NC}"

# Build image
echo -e "${BLUE}Building Docker image...${NC}"
docker build -t react-chatbot:latest .
echo -e "${GREEN}✓ Image built${NC}"

# Create namespace
echo -e "${BLUE}Creating namespace...${NC}"
kubectl create namespace react-chatbot || true
echo -e "${GREEN}✓ Namespace created${NC}"

# Deploy
echo -e "${BLUE}Deploying to Minikube...${NC}"
kubectl apply -f k8s/deployment.yaml -n react-chatbot
echo -e "${GREEN}✓ Deployment applied${NC}"

# Wait for pods
echo -e "${BLUE}Waiting for pods to be ready...${NC}"
kubectl rollout status deployment/react-chatbot -n react-chatbot --timeout=5m

echo ""
echo -e "${GREEN}=========================================="
echo "Setup Complete!"
echo "==========================================${NC}"
echo ""

echo -e "${BLUE}Cluster Info:${NC}"
minikube status
echo ""

echo -e "${BLUE}Pods:${NC}"
kubectl get pods -n react-chatbot
echo ""

echo -e "${BLUE}Services:${NC}"
kubectl get svc -n react-chatbot
echo ""

echo -e "${BLUE}Next Steps:${NC}"
echo "1. In a new terminal, run: minikube tunnel"
echo "2. Access app: http://localhost"
echo ""

echo -e "${BLUE}Useful commands:${NC}"
echo "  View logs: kubectl logs -f deployment/react-chatbot -n react-chatbot"
echo "  Dashboard: minikube dashboard"
echo "  Port forward: kubectl port-forward svc/react-chatbot-service 3000:80 -n react-chatbot"
echo "  Stop: minikube stop"
echo "  Delete: minikube delete"
echo ""

echo -e "${GREEN}✓ Minikube is ready!${NC}"

#!/bin/bash
# Minikube Terraform Deployment
# Deploy to local Minikube cluster using Terraform

set -e

echo "=========================================="
echo "Minikube Terraform Deployment"
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
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}kubectl not installed${NC}"
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Terraform not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites met${NC}"

# Start Minikube
echo -e "${BLUE}Starting Minikube...${NC}"
minikube start --cpus=4 --memory=4096

# Build Docker image
echo -e "${BLUE}Building Docker image...${NC}"
eval $(minikube docker-env)
docker build -t react-chatbot:latest .

# Navigate to terraform directory
cd terraform

# Initialize Terraform
echo -e "${BLUE}Initializing Terraform...${NC}"
terraform init

# Plan
echo -e "${BLUE}Planning deployment...${NC}"
terraform plan -var-file=minikube.tfvars -out=tfplan

# Apply
echo -e "${BLUE}Applying configuration...${NC}"
terraform apply tfplan

echo ""
echo -e "${GREEN}=========================================="
echo "Deployment Complete!"
echo "==========================================${NC}"
echo ""

echo -e "${BLUE}Next Steps:${NC}"
echo ""
echo "1. In a new terminal, run:"
echo "   minikube tunnel"
echo ""
echo "2. Access your app:"
echo "   http://localhost"
echo ""
echo "3. View logs:"
echo "   kubectl logs -f deployment/react-chatbot -n react-chatbot"
echo ""
echo "4. Open dashboard:"
echo "   minikube dashboard"
echo ""

echo -e "${GREEN}✓ Minikube deployment ready!${NC}"

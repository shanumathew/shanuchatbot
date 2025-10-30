#!/bin/bash
# Complete Docker + Minikube Deployment with Terraform
# Builds Docker image and deploys to Minikube using Terraform

set -e

echo "=========================================="
echo "Docker + Minikube Terraform Deployment"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker installed${NC}"

if ! command -v minikube &> /dev/null; then
    echo -e "${RED}Minikube not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Minikube installed${NC}"

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}kubectl not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ kubectl installed${NC}"

if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Terraform not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Terraform installed${NC}"

# Start Minikube
echo -e "${BLUE}Starting Minikube...${NC}"
minikube start --cpus=4 --memory=4096 --disk-size=50gb

# Enable addons
echo -e "${BLUE}Enabling Minikube addons...${NC}"
minikube addons enable registry
minikube addons enable metrics-server
minikube addons enable dashboard

# Configure Docker environment
echo -e "${BLUE}Configuring Docker environment...${NC}"
eval $(minikube docker-env)

# Navigate to terraform directory
cd terraform

# Initialize Terraform
echo -e "${BLUE}Initializing Terraform...${NC}"
terraform init

# Format code
echo -e "${BLUE}Formatting Terraform code...${NC}"
terraform fmt

# Validate configuration
echo -e "${BLUE}Validating Terraform configuration...${NC}"
terraform validate

# Plan deployment
echo -e "${BLUE}Planning deployment...${NC}"
terraform plan -var-file=docker-minikube.tfvars -out=tfplan

# Show plan
echo ""
echo -e "${YELLOW}Review the plan above. Continue? (yes/no)${NC}"
read -r RESPONSE

if [ "$RESPONSE" != "yes" ]; then
    echo -e "${YELLOW}Deployment cancelled${NC}"
    rm -f tfplan
    exit 0
fi

# Apply configuration
echo -e "${BLUE}Applying Terraform configuration...${NC}"
terraform apply tfplan

# Show deployment info
echo ""
echo -e "${GREEN}=========================================="
echo "Deployment Complete!"
echo "==========================================${NC}"
echo ""

echo -e "${BLUE}Deployment Information:${NC}"
terraform output deployment_status

echo ""
echo -e "${BLUE}Next Steps:${NC}"
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

echo -e "${GREEN}✓ Deployment ready!${NC}"

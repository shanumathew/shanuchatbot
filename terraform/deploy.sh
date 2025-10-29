#!/bin/bash
# Terraform Setup and Deployment Script
# This script initializes and applies Terraform configuration

set -e

echo "=========================================="
echo "Terraform Setup for React Chatbot"
echo "=========================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Terraform is installed
echo -e "${BLUE}Checking Terraform installation...${NC}"
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Terraform is not installed. Please install it first.${NC}"
    echo "Download from: https://www.terraform.io/downloads.html"
    exit 1
fi
echo -e "${GREEN}✓ Terraform $(terraform --version | grep -oP 'v\K[\d.]+')${NC}"

# Check if Azure CLI is installed
echo -e "${BLUE}Checking Azure CLI installation...${NC}"
if ! command -v az &> /dev/null; then
    echo -e "${RED}Azure CLI is not installed. Please install it first.${NC}"
    echo "Install: pip install azure-cli"
    exit 1
fi
echo -e "${GREEN}✓ Azure CLI $(az version --query '"azure-cli"' -o tsv 2>/dev/null || echo 'installed')${NC}"

# Check if logged in to Azure
echo -e "${BLUE}Checking Azure login status...${NC}"
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}Not logged in to Azure. Logging in...${NC}"
    az login
fi
SUBSCRIPTION=$(az account show --query name -o tsv)
echo -e "${GREEN}✓ Logged in as: $SUBSCRIPTION${NC}"

# Navigate to terraform directory
cd terraform

# Check if terraform.tfvars exists
if [ ! -f terraform.tfvars ]; then
    echo -e "${YELLOW}terraform.tfvars not found. Creating from example...${NC}"
    cp terraform.tfvars.example terraform.tfvars
    echo -e "${YELLOW}Please edit terraform.tfvars and add your Subscription ID${NC}"
    echo "Run: terraform account show --query id -o tsv"
    exit 1
fi

# Initialize Terraform
echo -e "${BLUE}Initializing Terraform...${NC}"
terraform init

# Validate configuration
echo -e "${BLUE}Validating configuration...${NC}"
terraform validate

# Format files
echo -e "${BLUE}Formatting Terraform files...${NC}"
terraform fmt

# Plan deployment
echo -e "${BLUE}Planning deployment...${NC}"
terraform plan -out=tfplan

# Ask for confirmation
echo ""
echo -e "${YELLOW}Review the plan above. Do you want to proceed? (yes/no)${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${RED}Deployment cancelled.${NC}"
    exit 0
fi

# Apply configuration
echo -e "${BLUE}Applying Terraform configuration...${NC}"
terraform apply tfplan

# Show outputs
echo ""
echo -e "${GREEN}=========================================="
echo "Deployment Complete!"
echo "==========================================${NC}"
echo ""

echo -e "${BLUE}Key Outputs:${NC}"
terraform output -json | jq 'to_entries[] | "\(.key): \(.value.value)"' -r

echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Build Docker image:"
echo "   docker build -t react-chatbot:latest .."
echo ""
echo "2. Push to ACR:"
ACR_SERVER=$(terraform output -raw acr_login_server)
echo "   docker tag react-chatbot:latest $ACR_SERVER/react-chatbot:latest"
echo "   docker push $ACR_SERVER/react-chatbot:latest"
echo ""
echo "3. Deploy to AKS (if using):"
echo "   az aks get-credentials --resource-group react-chatbot-rg --name react-chatbot-aks"
echo "   kubectl apply -f ../k8s/deployment.yaml"
echo ""
echo "4. Access App Service (if using):"
APP_URL=$(terraform output -raw app_service_url)
echo "   $APP_URL"
echo ""

echo -e "${GREEN}✓ Infrastructure deployed successfully!${NC}"

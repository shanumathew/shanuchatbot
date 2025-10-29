#!/bin/bash
# Terraform deployment script for Render
# Automates GitHub setup and provides Render deployment instructions

set -e

echo "=========================================="
echo "Render Deployment - Terraform Setup"
echo "=========================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check Terraform
echo -e "${BLUE}Checking Terraform...${NC}"
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Terraform not installed${NC}"
    exit 1
fi

# Navigate to terraform directory
cd terraform

# Check render.tfvars exists
if [ ! -f render.tfvars ]; then
    echo -e "${YELLOW}Creating render.tfvars from example...${NC}"
    cp render.tfvars.example render.tfvars
    echo -e "${RED}Please edit render.tfvars with your GitHub token${NC}"
    echo "Get token from: https://github.com/settings/tokens"
    exit 1
fi

# Initialize Terraform
echo -e "${BLUE}Initializing Terraform...${NC}"
terraform init

# Validate
echo -e "${BLUE}Validating configuration...${NC}"
terraform validate

# Plan
echo -e "${BLUE}Planning deployment...${NC}"
terraform plan -var-file=render.tfvars -out=tfplan

# Apply
echo -e "${BLUE}Applying configuration...${NC}"
terraform apply tfplan

echo ""
echo -e "${GREEN}=========================================="
echo "Setup Complete!"
echo "==========================================${NC}"
echo ""

echo -e "${BLUE}Next Steps:${NC}"
echo ""
echo "1. Push code to GitHub:"
echo "   cd .."
echo "   git add ."
echo "   git commit -m 'Configure for Render'"
echo "   git push origin master"
echo ""
echo "2. Go to https://render.com/"
echo "3. Sign in with GitHub"
echo "4. Click 'New +' → 'Web Service'"
echo "5. Select your repository"
echo "6. Configure and deploy"
echo ""
echo -e "${GREEN}✓ Terraform setup complete!${NC}"

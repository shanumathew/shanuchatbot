# Terraform Configuration for React Chatbot - Azure Deployment

Complete Terraform setup for deploying React Chatbot to Azure with App Service and AKS.

## 📋 Prerequisites

```bash
# Install Terraform
# Windows (using Chocolatey)
choco install terraform

# Or download from: https://www.terraform.io/downloads.html

# Install Azure CLI
pip install azure-cli

# Verify installation
terraform --version
az --version
```

## 🚀 Quick Start

### Step 1: Login to Azure
```bash
az login
az account show  # Copy the Subscription ID
```

### Step 2: Create terraform.tfvars
```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars` and fill in:
```hcl
subscription_id = "YOUR_SUBSCRIPTION_ID"  # From az account show
tenant_id       = "7c5e3930-c4ea-40ac-87dc-40c742b23dd5"  # Already provided
```

### Step 3: Initialize Terraform
```bash
cd terraform
terraform init
```

### Step 4: Plan Deployment
```bash
terraform plan -out=tfplan
```
Review the output to see what will be created.

### Step 5: Apply Configuration
```bash
terraform apply tfplan
```

This will create:
- ✅ Resource Group
- ✅ Container Registry
- ✅ App Service Plan & App Service
- ✅ AKS Cluster (3 nodes with auto-scaling)
- ✅ Log Analytics & Application Insights
- ✅ Network Security Group

### Step 6: Get Outputs
```bash
terraform output
terraform output app_service_url
terraform output aks_cluster_id
```

---

## 📁 File Structure

```
terraform/
├── main.tf                      # Main resource definitions
├── variables.tf                 # Variable declarations
├── outputs.tf                   # Output values
├── terraform.tfvars.example     # Example configuration
├── terraform.tfvars             # Your configuration (create from example)
└── README.md                    # This file
```

---

## 🔧 Configuration Options

### Choose Deployment Type

**Option A: App Service Only** (Easiest)
```hcl
# In terraform.tfvars
app_service_name = "react-chatbot-app"
# AKS will still be created, disable if not needed
```

**Option B: AKS Only** (Production)
```hcl
# In terraform.tfvars
aks_cluster_name = "react-chatbot-aks"
```

**Option C: Both App Service & AKS** (Default)
```hcl
# Both resources created
```

### Customize AKS

```hcl
# Node configuration
aks_node_count = 3        # Initial nodes
aks_min_count  = 2        # Min nodes (auto-scaling)
aks_max_count  = 10       # Max nodes (auto-scaling)
aks_vm_size    = "Standard_B2s"  # VM size

# Add additional node pool
create_additional_node_pool = true
```

### Customize App Service

```hcl
# App Service tier
app_service_sku = "B2"  # Options:
                        # B1 - $12.50/month (Basic)
                        # B2 - $50/month (Basic)
                        # B3 - $100/month (Basic)
                        # S1 - $74/month (Standard)
                        # P1V2 - $150/month (Premium)
```

---

## 📊 Useful Terraform Commands

```bash
# Initialize working directory
terraform init

# Format configuration files
terraform fmt

# Validate configuration
terraform validate

# Plan changes (dry-run)
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show

# List resources
terraform state list

# Show specific resource
terraform state show azurerm_resource_group.main

# Destroy everything
terraform destroy

# Destroy specific resource
terraform destroy -target azurerm_linux_web_app.app_service
```

---

## 🔐 Managing Secrets

### Option 1: Environment Variables
```bash
export ARM_SUBSCRIPTION_ID="YOUR_SUBSCRIPTION_ID"
export ARM_TENANT_ID="7c5e3930-c4ea-40ac-87dc-40c742b23dd5"
export ARM_CLIENT_ID="YOUR_SERVICE_PRINCIPAL_ID"
export ARM_CLIENT_SECRET="YOUR_SERVICE_PRINCIPAL_SECRET"

# Then run terraform
terraform apply
```

### Option 2: terraform.tfvars (Less Secure)
```hcl
# terraform/terraform.tfvars
subscription_id = "YOUR_SUBSCRIPTION_ID"
tenant_id       = "7c5e3930-c4ea-40ac-87dc-40c742b23dd5"
```

### Option 3: Service Principal (Recommended)
```bash
# Create service principal
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID"

# Use the output in terraform.tfvars:
client_id     = "appId"
client_secret = "password"
```

---

## 📤 Deploying Your Docker Image

After infrastructure is created:

```bash
# Build Docker image
docker build -t react-chatbot:latest .

# Get ACR login server
ACR_SERVER=$(terraform output -raw acr_login_server)

# Login to ACR
az acr login --name shanumathew

# Tag image
docker tag react-chatbot:latest ${ACR_SERVER}/react-chatbot:latest

# Push image
docker push ${ACR_SERVER}/react-chatbot:latest
```

---

## 🚀 Accessing Your Application

### App Service
```bash
# Get URL
terraform output app_service_url

# Example: https://react-chatbot-app.azurewebsites.net
```

### AKS
```bash
# Get credentials
az aks get-credentials --resource-group react-chatbot-rg --name react-chatbot-aks

# Deploy application
kubectl apply -f ../k8s/deployment.yaml

# Get service IP
kubectl get svc react-chatbot-service
```

---

## 💰 Cost Estimation

### Minimal Setup (Development)
- App Service (B1): $12.50/month
- Container Registry: $5/month
- **Total**: ~$17.50/month

### Standard Setup (Production - Recommended)
- App Service (B2): $50/month
- Container Registry: $5/month
- **Total**: ~$55/month

### High Availability Setup
- AKS (3 x B2s nodes): $150/month
- Container Registry: $5/month
- Load Balancer: $20/month
- **Total**: ~$175/month

---

## 🔄 Update Configuration

### Scaling Up
```hcl
# In terraform.tfvars
app_service_sku = "P1V2"  # Upgrade App Service
aks_max_count   = 20      # Increase max AKS nodes

# Apply changes
terraform apply
```

### Adding Features
```hcl
# Enable additional node pool
create_additional_node_pool = true

# Apply changes
terraform apply
```

---

## 🆘 Troubleshooting

### "Authentication required"
```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### "Resource already exists"
```bash
# Import existing resource
terraform import azurerm_resource_group.main /subscriptions/SUB_ID/resourceGroups/react-chatbot-rg

# Or destroy and recreate
terraform destroy
terraform apply
```

### "Insufficient permissions"
```bash
# Create service principal with proper permissions
az ad sp create-for-rbac --role="Owner" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID"
```

### "State locked"
```bash
# Remove lock
terraform force-unlock LOCK_ID
```

---

## 📚 Remote State (Optional)

To store state in Azure Storage:

### Step 1: Create Storage Account
```bash
az storage account create \
  --name tfstg1234567890 \
  --resource-group react-chatbot-rg \
  --location eastus \
  --sku Standard_LRS

az storage container create \
  --name tfstate \
  --account-name tfstg1234567890
```

### Step 2: Update main.tf
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "react-chatbot-rg"
    storage_account_name = "tfstg1234567890"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
```

### Step 3: Reinitialize
```bash
terraform init
```

---

## ✅ Verification Checklist

- [ ] Azure CLI installed and logged in
- [ ] Terraform installed
- [ ] terraform.tfvars created with Subscription ID
- [ ] `terraform init` completed successfully
- [ ] `terraform plan` shows expected resources
- [ ] `terraform apply` completes without errors
- [ ] Resources visible in Azure Portal
- [ ] Docker image pushed to ACR
- [ ] Application deployed and accessible

---

## 🎯 Next Steps

1. **Deploy Infrastructure**: `terraform apply`
2. **Build & Push Image**: `docker push <ACR>/react-chatbot:latest`
3. **Deploy Application**: `kubectl apply -f k8s/deployment.yaml`
4. **Monitor**: Check Azure Portal or `kubectl get pods`
5. **Scale**: Adjust `app_service_sku` or `aks_max_count` in terraform.tfvars

---

## 📞 Support

For issues:
1. Check Terraform logs: `terraform apply -verbose`
2. Verify credentials: `az account show`
3. Check Azure Portal for resource status
4. Review Azure CLI documentation: `az help`

---

**Infrastructure as Code with Terraform - Ready to Deploy!** 🚀

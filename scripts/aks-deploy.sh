#!/bin/bash
# Azure Kubernetes Service (AKS) Setup Script
# Deploy React Chatbot to AKS

set -e

echo "=========================================="
echo "Azure Kubernetes Service Setup"
echo "=========================================="

# Variables
RESOURCE_GROUP="react-chatbot-rg"
CLUSTER_NAME="react-chatbot-aks"
LOCATION="eastus"
NODE_COUNT=3
VM_SIZE="Standard_B2s"
REGISTRY_NAME="shanumathew"
ACR_RESOURCE_GROUP="react-chatbot-rg"

echo ""
echo "Configuration:"
echo "  Resource Group: $RESOURCE_GROUP"
echo "  Cluster Name: $CLUSTER_NAME"
echo "  Location: $LOCATION"
echo "  Node Count: $NODE_COUNT"
echo "  VM Size: $VM_SIZE"
echo ""

# Step 1: Create resource group (if not exists)
echo "Step 1: Creating Resource Group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Step 2: Create AKS cluster
echo "Step 2: Creating AKS Cluster (this takes 5-10 minutes)..."
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count $NODE_COUNT \
  --vm-set-type VirtualMachineScaleSets \
  --load-balancer-sku standard \
  --enable-managed-identity \
  --network-plugin azure \
  --network-policy azure \
  --docker-bridge-address 172.17.0.1/16 \
  --service-cidr 10.0.0.0/16 \
  --dns-service-ip 10.0.0.10 \
  --node-vm-size $VM_SIZE \
  --zones 1 2 3 \
  --enable-cluster-autoscaling \
  --min-count 2 \
  --max-count 10 \
  --enable-rbac \
  --enable-monitoring \
  --log-analytics-workspace-resource-id "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/aks-workspace"

echo "✓ AKS Cluster created!"

# Step 3: Get AKS credentials
echo "Step 3: Getting AKS Credentials..."
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --overwrite-existing

echo "✓ Credentials configured for kubectl"

# Step 4: Verify cluster connection
echo "Step 4: Verifying Cluster Connection..."
kubectl cluster-info
kubectl get nodes

# Step 5: Create namespace
echo "Step 5: Creating Kubernetes Namespace..."
kubectl create namespace react-chatbot || true
kubectl label namespace react-chatbot purpose=production --overwrite

# Step 6: Create image pull secret
echo "Step 6: Creating Image Pull Secret..."
ACR_LOGIN_SERVER="${REGISTRY_NAME}.azurecr.io"
ACR_USERNAME=$(az acr credential show --name $REGISTRY_NAME --resource-group $ACR_RESOURCE_GROUP --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name $REGISTRY_NAME --resource-group $ACR_RESOURCE_GROUP --query passwords[0].value -o tsv)

kubectl create secret docker-registry acr-secret \
  --docker-server=$ACR_LOGIN_SERVER \
  --docker-username=$ACR_USERNAME \
  --docker-password=$ACR_PASSWORD \
  --docker-email=admin@example.com \
  -n react-chatbot || true

echo "✓ Image pull secret created"

# Step 7: Deploy application
echo "Step 7: Deploying Application..."
kubectl apply -f k8s/deployment.yaml -n react-chatbot

# Step 8: Wait for deployment
echo "Step 8: Waiting for Deployment (this takes 1-2 minutes)..."
kubectl rollout status deployment/react-chatbot -n react-chatbot --timeout=5m

# Step 9: Get service information
echo "Step 9: Getting Service Information..."
echo ""
echo "=========================================="
echo "DEPLOYMENT COMPLETE!"
echo "=========================================="
echo ""

SERVICE_IP=$(kubectl get svc react-chatbot-service -n react-chatbot -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "Pending...")
echo "Service IP/URL: http://${SERVICE_IP}"
echo ""

# Step 10: Show resources
echo "Kubernetes Resources:"
kubectl get all -n react-chatbot

echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo "1. Wait for Load Balancer IP to be assigned"
echo "   Command: kubectl get svc react-chatbot-service -n react-chatbot"
echo ""
echo "2. Access your app:"
echo "   http://${SERVICE_IP}"
echo ""
echo "3. Monitor deployment:"
echo "   kubectl logs -f deployment/react-chatbot -n react-chatbot"
echo ""
echo "4. Scale deployment:"
echo "   kubectl scale deployment react-chatbot --replicas=5 -n react-chatbot"
echo ""
echo "5. View metrics:"
echo "   kubectl top nodes"
echo "   kubectl top pods -n react-chatbot"
echo ""
echo "6. Delete deployment:"
echo "   kubectl delete namespace react-chatbot"
echo ""

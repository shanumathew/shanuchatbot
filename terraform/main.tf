terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Uncomment for remote state (using Azure Storage)
  # backend "azurerm" {
  #   resource_group_name  = "terraform-rg"
  #   storage_account_name = "tfstorageaccount"
  #   container_name       = "tfstate"
  #   key                  = "prod.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
  
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = local.common_tags
}

# Container Registry
resource "azurerm_container_registry" "acr" {
  name                = var.registry_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.registry_sku
  admin_enabled       = true

  tags = local.common_tags
}

# Output ACR credentials
output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "ACR Login Server"
}

output "acr_admin_username" {
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
  description = "ACR Admin Username"
}

output "acr_admin_password" {
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
  description = "ACR Admin Password"
}

# App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku

  tags = local.common_tags
}

# App Service
resource "azurerm_linux_web_app" "app_service" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    always_on         = true
    minimum_tls_version = "1.2"
    
    application_stack {
      docker_image_name   = "${azurerm_container_registry.acr.login_server}/react-chatbot:latest"
      docker_registry_url = "https://${azurerm_container_registry.acr.login_server}"
    }
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "3000"
    NODE_ENV                            = "production"
    DOCKER_REGISTRY_SERVER_URL          = "https://${azurerm_container_registry.acr.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME     = azurerm_container_registry.acr.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD     = azurerm_container_registry.acr.admin_password
  }

  tags = local.common_tags

  depends_on = [azurerm_container_registry.acr]
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = var.aks_dns_prefix

  default_node_pool {
    name                = "default"
    node_count          = var.aks_node_count
    vm_size             = var.aks_vm_size
    zones               = [1, 2, 3]
    enable_auto_scaling = true
    min_count           = var.aks_min_count
    max_count           = var.aks_max_count
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.0.0.0/16"
    dns_service_ip    = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  api_server_authorized_ip_ranges = var.aks_authorized_ip_ranges

  tags = local.common_tags

  depends_on = [azurerm_resource_group.main]
}

# AKS Node Pool (optional - for additional nodes)
resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  count                 = var.create_additional_node_pool ? 1 : 0
  name                  = "pool2"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  node_count            = 2
  vm_size               = var.aks_vm_size
  zones                 = [1, 2, 3]
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 5

  tags = local.common_tags
}

# Output AKS Info
output "aks_cluster_id" {
  value       = azurerm_kubernetes_cluster.aks.id
  description = "AKS Cluster ID"
}

output "aks_kube_config" {
  value       = azurerm_kubernetes_cluster.aks.kube_config
  sensitive   = true
  description = "AKS Kubernetes Config"
}

output "aks_client_certificate" {
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].client_certificate
  sensitive   = true
  description = "AKS Client Certificate"
}

output "app_service_url" {
  value       = "https://${azurerm_linux_web_app.app_service.default_hostname}"
  description = "App Service URL"
}

# Application Insights (Monitoring)
resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.common_tags
}

resource "azurerm_application_insights" "app_insights" {
  name                = var.application_insights_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  tags = local.common_tags
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}

# Storage Account for Terraform State (optional)
resource "azurerm_storage_account" "terraform_state" {
  count                    = var.create_terraform_state_storage ? 1 : 0
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.common_tags
}

resource "azurerm_storage_container" "terraform_state" {
  count                 = var.create_terraform_state_storage ? 1 : 0
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.terraform_state[0].name
  container_access_type = "private"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Service Principal Client ID"
  type        = string
  sensitive   = true
  default     = ""
}

variable "client_secret" {
  description = "Service Principal Client Secret"
  type        = string
  sensitive   = true
  default     = ""
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "react-chatbot-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# Container Registry Variables
variable "registry_name" {
  description = "Name of the container registry (must be globally unique, lowercase)"
  type        = string
  default     = "shanumathew"
}

variable "registry_sku" {
  description = "Container Registry SKU"
  type        = string
  default     = "Basic"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.registry_sku)
    error_message = "Registry SKU must be Basic, Standard, or Premium."
  }
}

# App Service Variables
variable "app_service_plan_name" {
  description = "App Service Plan name"
  type        = string
  default     = "react-chatbot-plan"
}

variable "app_service_name" {
  description = "App Service name (must be globally unique)"
  type        = string
  default     = "react-chatbot-app"
}

variable "app_service_sku" {
  description = "App Service SKU (B1, B2, B3, S1, etc.)"
  type        = string
  default     = "B2"
}

# AKS Variables
variable "aks_cluster_name" {
  description = "AKS Cluster name"
  type        = string
  default     = "react-chatbot-aks"
}

variable "aks_dns_prefix" {
  description = "AKS DNS prefix"
  type        = string
  default     = "react-chatbot"
}

variable "aks_node_count" {
  description = "Initial number of AKS nodes"
  type        = number
  default     = 3
}

variable "aks_min_count" {
  description = "Minimum number of nodes (auto-scaling)"
  type        = number
  default     = 2
}

variable "aks_max_count" {
  description = "Maximum number of nodes (auto-scaling)"
  type        = number
  default     = 10
}

variable "aks_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "aks_authorized_ip_ranges" {
  description = "Authorized IP ranges for AKS API server"
  type        = list(string)
  default     = []
}

variable "create_additional_node_pool" {
  description = "Create an additional node pool"
  type        = bool
  default     = false
}

# Monitoring Variables
variable "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  type        = string
  default     = "react-chatbot-logs"
}

variable "application_insights_name" {
  description = "Application Insights name"
  type        = string
  default     = "react-chatbot-insights"
}

# Network Variables
variable "nsg_name" {
  description = "Network Security Group name"
  type        = string
  default     = "react-chatbot-nsg"
}

# Storage State Variables
variable "create_terraform_state_storage" {
  description = "Create storage account for Terraform state"
  type        = bool
  default     = false
}

variable "storage_account_name" {
  description = "Storage account name for Terraform state"
  type        = string
  default     = ""
}

# Docker Image
variable "docker_image_name" {
  description = "Docker image name"
  type        = string
  default     = "react-chatbot"
}

variable "docker_image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = "react-chatbot"
    Terraform   = "true"
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}

output "resource_group_id" {
  value       = azurerm_resource_group.main.id
  description = "Resource Group ID"
}

output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Resource Group Name"
}

output "acr_registry_url" {
  value       = "https://${azurerm_container_registry.acr.login_server}"
  description = "ACR Registry URL"
}

output "aks_host" {
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
  sensitive   = true
  description = "AKS Host"
}

output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.main.id
  description = "Log Analytics Workspace ID"
}

output "application_insights_instrumentation_key" {
  value       = azurerm_application_insights.app_insights.instrumentation_key
  sensitive   = true
  description = "Application Insights Instrumentation Key"
}

output "nsg_id" {
  value       = azurerm_network_security_group.nsg.id
  description = "Network Security Group ID"
}

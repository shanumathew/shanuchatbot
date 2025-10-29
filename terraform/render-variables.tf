variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "GitHub username/organization"
  type        = string
  default     = "shanumathew"
}

variable "repository_name" {
  description = "GitHub repository name"
  type        = string
  default     = "shanuchatbot"
}

variable "render_api_key" {
  description = "Render API Key (optional)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "render_service_id" {
  description = "Render Service ID (optional)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "app_name" {
  description = "App name for Render"
  type        = string
  default     = "react-chatbot"
}

variable "node_version" {
  description = "Node.js version"
  type        = string
  default     = "18"
}

variable "render_plan" {
  description = "Render plan type"
  type        = string
  default     = "free"
  validation {
    condition     = contains(["free", "starter", "standard", "pro"], var.render_plan)
    error_message = "Render plan must be: free, starter, standard, or pro"
  }
}

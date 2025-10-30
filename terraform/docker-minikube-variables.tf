# Docker + Minikube Terraform Variables

# Docker Configuration
variable "docker_host" {
  description = "Docker host (leave empty for local)"
  type        = string
  default     = ""
}

variable "docker_build_context" {
  description = "Path to build context (project root)"
  type        = string
  default     = ".."
}

variable "image_registry" {
  description = "Docker image registry"
  type        = string
  default     = "docker.io"
}

variable "image_name" {
  description = "Docker image name"
  type        = string
  default     = "react-chatbot"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

# Kubernetes Configuration
variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "react-chatbot"
}

variable "deployment_name" {
  description = "Kubernetes deployment name"
  type        = string
  default     = "react-chatbot"
}

variable "service_name" {
  description = "Kubernetes service name"
  type        = string
  default     = "react-chatbot-service"
}

# Replica Configuration
variable "replicas" {
  description = "Initial number of replicas"
  type        = number
  default     = 2
  validation {
    condition     = var.replicas >= 1 && var.replicas <= 10
    error_message = "Replicas must be between 1 and 10"
  }
}

variable "min_replicas" {
  description = "Minimum replicas for autoscaling"
  type        = number
  default     = 1
  validation {
    condition     = var.min_replicas >= 1
    error_message = "Min replicas must be at least 1"
  }
}

variable "max_replicas" {
  description = "Maximum replicas for autoscaling"
  type        = number
  default     = 5
  validation {
    condition     = var.max_replicas >= var.min_replicas
    error_message = "Max replicas must be >= min replicas"
  }
}

# Resource Configuration
variable "cpu_request" {
  description = "CPU request per pod"
  type        = string
  default     = "250m"
}

variable "cpu_limit" {
  description = "CPU limit per pod"
  type        = string
  default     = "500m"
}

variable "memory_request" {
  description = "Memory request per pod"
  type        = string
  default     = "256Mi"
}

variable "memory_limit" {
  description = "Memory limit per pod"
  type        = string
  default     = "512Mi"
}

# Autoscaling Configuration
variable "cpu_target_utilization" {
  description = "Target CPU utilization percentage"
  type        = number
  default     = 70
  validation {
    condition     = var.cpu_target_utilization > 0 && var.cpu_target_utilization <= 100
    error_message = "CPU utilization must be between 1 and 100"
  }
}

variable "memory_target_utilization" {
  description = "Target memory utilization percentage"
  type        = number
  default     = 80
  validation {
    condition     = var.memory_target_utilization > 0 && var.memory_target_utilization <= 100
    error_message = "Memory utilization must be between 1 and 100"
  }
}

# Service Configuration
variable "service_type" {
  description = "Kubernetes service type"
  type        = string
  default     = "LoadBalancer"
  validation {
    condition     = contains(["LoadBalancer", "NodePort", "ClusterIP"], var.service_type)
    error_message = "Service type must be LoadBalancer, NodePort, or ClusterIP"
  }
}

variable "session_affinity" {
  description = "Session affinity"
  type        = string
  default     = "None"
  validation {
    condition     = contains(["None", "ClientIP"], var.session_affinity)
    error_message = "Session affinity must be None or ClientIP"
  }
}

# Environment Configuration
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production"
  }
}

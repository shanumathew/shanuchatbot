terraform {
  required_version = ">= 1.0"
  
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# Configure Kubernetes provider to use Minikube
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = "minikube"
}

# Local provider for file operations
provider "local" {}

# Namespace
resource "kubernetes_namespace" "chatbot" {
  metadata {
    name = var.namespace
  }
}

# ConfigMap for environment variables
resource "kubernetes_config_map" "chatbot_config" {
  metadata {
    name      = "chatbot-config"
    namespace = kubernetes_namespace.chatbot.metadata[0].name
  }

  data = {
    NODE_ENV = var.environment
    PORT     = "3000"
  }
}

# Deployment
resource "kubernetes_deployment" "chatbot" {
  metadata {
    name      = "react-chatbot"
    namespace = kubernetes_namespace.chatbot.metadata[0].name
    labels = {
      app = "react-chatbot"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "react-chatbot"
      }
    }

    template {
      metadata {
        labels = {
          app = "react-chatbot"
        }
      }

      spec {
        container {
          image             = "${var.image_name}:${var.image_tag}"
          image_pull_policy = "IfNotPresent"
          name              = "chatbot"

          port {
            container_port = 3000
            name           = "http"
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.chatbot_config.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 2
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.chatbot]
}

# Service
resource "kubernetes_service" "chatbot" {
  metadata {
    name      = "react-chatbot-service"
    namespace = kubernetes_namespace.chatbot.metadata[0].name
    labels = {
      app = "react-chatbot"
    }
  }

  spec {
    selector = {
      app = "react-chatbot"
    }

    port {
      port        = 80
      target_port = 3000
      protocol    = "TCP"
    }

    type = var.service_type
  }

  depends_on = [kubernetes_deployment.chatbot]
}

# Horizontal Pod Autoscaler
resource "kubernetes_horizontal_pod_autoscaler_v2" "chatbot" {
  metadata {
    name      = "react-chatbot-hpa"
    namespace = kubernetes_namespace.chatbot.metadata[0].name
  }

  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.chatbot.metadata[0].name
    }

    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 70
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = 80
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.chatbot]
}

# Output information
output "namespace" {
  value       = kubernetes_namespace.chatbot.metadata[0].name
  description = "Kubernetes namespace"
}

output "deployment_name" {
  value       = kubernetes_deployment.chatbot.metadata[0].name
  description = "Deployment name"
}

output "service_name" {
  value       = kubernetes_service.chatbot.metadata[0].name
  description = "Service name"
}

output "deployment_instructions" {
  value = <<-EOT
    
    ========================================
    Minikube Deployment Complete!
    ========================================
    
    Cluster: Minikube
    Namespace: ${kubernetes_namespace.chatbot.metadata[0].name}
    
    Check status:
      kubectl get pods -n ${kubernetes_namespace.chatbot.metadata[0].name}
      kubectl get svc -n ${kubernetes_namespace.chatbot.metadata[0].name}
    
    View logs:
      kubectl logs -f deployment/react-chatbot -n ${kubernetes_namespace.chatbot.metadata[0].name}
    
    Expose service:
      minikube tunnel
    
    Access:
      http://localhost
    
    Open dashboard:
      minikube dashboard
    
    ========================================
  EOT
}

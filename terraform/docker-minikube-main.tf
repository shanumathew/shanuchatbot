terraform {
  required_version = ">= 1.0"
  
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
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

# Docker Provider - for building and managing images
provider "docker" {
  host = var.docker_host
}

# Kubernetes Provider - for Minikube cluster
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = "minikube"
}

# Local provider for file operations
provider "local" {}

# ============================================================
# DOCKER IMAGE BUILD
# ============================================================

# Build Docker image from Dockerfile
resource "docker_image" "chatbot" {
  name = "${var.image_registry}/${var.image_name}:${var.image_tag}"

  build {
    context    = var.docker_build_context
    dockerfile = "Dockerfile"
    tag = [
      "${var.image_registry}/${var.image_name}:${var.image_tag}",
      "${var.image_registry}/${var.image_name}:latest"
    ]
  }

  triggers = {
    dir_sha1 = filebase64sha256("${var.docker_build_context}/Dockerfile")
  }
}

# ============================================================
# KUBERNETES RESOURCES
# ============================================================

# Namespace
resource "kubernetes_namespace" "chatbot" {
  metadata {
    name = var.namespace
    labels = {
      managed_by = "terraform"
      app        = "react-chatbot"
    }
  }
}

# ConfigMap for environment variables
resource "kubernetes_config_map" "chatbot_config" {
  metadata {
    name      = "chatbot-config"
    namespace = kubernetes_namespace.chatbot.metadata[0].name
    labels = {
      app = "react-chatbot"
    }
  }

  data = {
    NODE_ENV = var.environment
    PORT     = "3000"
  }
}

# Deployment
resource "kubernetes_deployment" "chatbot" {
  metadata {
    name      = var.deployment_name
    namespace = kubernetes_namespace.chatbot.metadata[0].name
    labels = {
      app     = "react-chatbot"
      version = var.image_tag
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "react-chatbot"
      }
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = 1
        max_unavailable = 0
      }
    }

    template {
      metadata {
        labels = {
          app = "react-chatbot"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "3000"
        }
      }

      spec {
        # Image pull policy - IfNotPresent for Minikube
        container {
          name              = "chatbot"
          image             = docker_image.chatbot.image_id
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 3000
            name           = "http"
            protocol       = "TCP"
          }

          # Environment variables from ConfigMap
          env_from {
            config_map_ref {
              name = kubernetes_config_map.chatbot_config.metadata[0].name
            }
          }

          # Resource requests and limits
          resources {
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }

          # Liveness probe
          liveness_probe {
            http_get {
              path   = "/"
              port   = 3000
              scheme = "HTTP"
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            success_threshold     = 1
            failure_threshold     = 3
          }

          # Readiness probe
          readiness_probe {
            http_get {
              path   = "/"
              port   = 3000
              scheme = "HTTP"
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            success_threshold     = 1
            failure_threshold     = 2
          }

          # Volume mounts
          volume_mount {
            name       = "app-logs"
            mount_path = "/var/log/app"
          }
        }

        # Volumes
        volume {
          name = "app-logs"
          empty_dir {
            size_limit = "1Gi"
          }
        }

        # Pod security context
        security_context {
          run_as_non_root = true
          run_as_user     = 1000
        }

        # Pod disruption budget
        termination_grace_period_seconds = 30
      }
    }
  }

  depends_on = [
    kubernetes_namespace.chatbot,
    docker_image.chatbot
  ]

  wait_for_rollout = true
}

# Service
resource "kubernetes_service" "chatbot" {
  metadata {
    name      = var.service_name
    namespace = kubernetes_namespace.chatbot.metadata[0].name
    labels = {
      app = "react-chatbot"
    }
  }

  spec {
    selector = {
      app = "react-chatbot"
    }

    type = var.service_type

    port {
      name        = "http"
      port        = 80
      target_port = 3000
      protocol    = "TCP"
    }

    session_affinity = var.session_affinity
  }

  depends_on = [kubernetes_deployment.chatbot]
}

# Horizontal Pod Autoscaler
resource "kubernetes_horizontal_pod_autoscaler_v2" "chatbot" {
  metadata {
    name      = "${var.deployment_name}-hpa"
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
          average_utilization = var.cpu_target_utilization
        }
      }
    }

    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type                = "Utilization"
          average_utilization = var.memory_target_utilization
        }
      }
    }

    behavior {
      scale_down {
        stabilization_window_seconds = 300
        policies {
          type           = "Percent"
          value          = 50
          period_seconds = 60
        }
      }
      scale_up {
        stabilization_window_seconds = 0
        policies {
          type           = "Percent"
          value          = 100
          period_seconds = 30
        }
        policies {
          type           = "Pods"
          value          = 2
          period_seconds = 60
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.chatbot]
}

# Pod Disruption Budget
resource "kubernetes_pod_disruption_budget_v1" "chatbot" {
  metadata {
    name      = "${var.deployment_name}-pdb"
    namespace = kubernetes_namespace.chatbot.metadata[0].name
  }

  spec {
    min_available = 1
    selector {
      match_labels = {
        app = "react-chatbot"
      }
    }
  }
}

# ============================================================
# OUTPUTS
# ============================================================

output "docker_image_id" {
  value       = docker_image.chatbot.image_id
  description = "Docker image ID"
}

output "docker_image_name" {
  value       = docker_image.chatbot.name
  description = "Docker image name"
}

output "kubernetes_namespace" {
  value       = kubernetes_namespace.chatbot.metadata[0].name
  description = "Kubernetes namespace"
}

output "deployment_name" {
  value       = kubernetes_deployment.chatbot.metadata[0].name
  description = "Kubernetes deployment name"
}

output "service_name" {
  value       = kubernetes_service.chatbot.metadata[0].name
  description = "Kubernetes service name"
}

output "service_endpoint" {
  value       = "http://${kubernetes_service.chatbot.metadata[0].name}.${kubernetes_namespace.chatbot.metadata[0].name}.svc.cluster.local"
  description = "Kubernetes service endpoint"
}

output "deployment_status" {
  value = <<-EOT
    
    ========================================
    Docker + Minikube Deployment Complete!
    ========================================
    
    Docker Image:
      ID: ${docker_image.chatbot.image_id}
      Name: ${docker_image.chatbot.name}
    
    Kubernetes Cluster: Minikube
      Namespace: ${kubernetes_namespace.chatbot.metadata[0].name}
      Deployment: ${kubernetes_deployment.chatbot.metadata[0].name}
      Service: ${kubernetes_service.chatbot.metadata[0].name}
      Replicas: ${var.replicas}
      Min/Max: ${var.min_replicas}-${var.max_replicas}
    
    Check Status:
      kubectl get pods -n ${kubernetes_namespace.chatbot.metadata[0].name}
      kubectl get svc -n ${kubernetes_namespace.chatbot.metadata[0].name}
      kubectl get deployment -n ${kubernetes_namespace.chatbot.metadata[0].name}
    
    View Logs:
      kubectl logs -f deployment/${kubernetes_deployment.chatbot.metadata[0].name} -n ${kubernetes_namespace.chatbot.metadata[0].name}
    
    Expose Service:
      minikube tunnel
    
    Access Application:
      http://localhost
    
    Open Dashboard:
      minikube dashboard
    
    Port Forward (alternative to tunnel):
      kubectl port-forward svc/${kubernetes_service.chatbot.metadata[0].name} 3000:80 -n ${kubernetes_namespace.chatbot.metadata[0].name}
    
    ========================================
  EOT
}

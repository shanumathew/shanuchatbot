# Docker + Minikube Terraform Configuration

# Docker settings
docker_host            = ""  # Leave empty for local Docker
docker_build_context   = ".."  # Path to project root
image_registry         = "docker.io"
image_name             = "react-chatbot"
image_tag              = "latest"

# Kubernetes settings
kubeconfig_path        = "~/.kube/config"
namespace              = "react-chatbot"
deployment_name        = "react-chatbot"
service_name           = "react-chatbot-service"

# Replica settings
replicas               = 2
min_replicas           = 1
max_replicas           = 5

# Resource settings
cpu_request            = "250m"
cpu_limit              = "500m"
memory_request         = "256Mi"
memory_limit           = "512Mi"

# Autoscaling settings
cpu_target_utilization = 70
memory_target_utilization = 80

# Service settings
service_type           = "LoadBalancer"
session_affinity       = "None"

# Environment
environment            = "production"

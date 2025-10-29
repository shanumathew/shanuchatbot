# Minikube Terraform Variables
kubeconfig_path = "~/.kube/config"
namespace       = "react-chatbot"
environment     = "development"
replicas        = 2
min_replicas    = 1
max_replicas    = 5
image_name      = "react-chatbot"
image_tag       = "latest"
service_type    = "LoadBalancer"

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = var.github_owner
  token = var.github_token
}

# Repository configuration
resource "github_repository" "chatbot" {
  name        = var.repository_name
  description = "React Chatbot with Gemini AI - Render Deployment"
  
  visibility  = "public"
  has_issues  = true
  has_wiki    = false
  
  auto_init = false
}

# GitHub Secrets for Render (if needed for CI/CD)
resource "github_actions_secret" "render_api_key" {
  repository       = github_repository.chatbot.name
  secret_name      = "RENDER_API_KEY"
  plaintext_value  = var.render_api_key
}

resource "github_actions_secret" "render_service_id" {
  repository       = github_repository.chatbot.name
  secret_name      = "RENDER_SERVICE_ID"
  plaintext_value  = var.render_service_id
}

# Output deployment information
output "github_repo_url" {
  value       = github_repository.chatbot.html_url
  description = "GitHub Repository URL"
}

output "render_dashboard_url" {
  value       = "https://dashboard.render.com/"
  description = "Render Dashboard URL"
}

output "render_deployment_url" {
  value       = "https://react-chatbot.onrender.com"
  description = "Your Render App URL (after deployment)"
}

output "deployment_instructions" {
  value = <<-EOT
    
    ========================================
    Render Deployment Instructions
    ========================================
    
    1. Push code to GitHub:
       git add .
       git commit -m "Ready for Render"
       git push origin master
    
    2. Go to https://render.com/
    
    3. Sign in with GitHub
    
    4. Click "New +" → "Web Service"
    
    5. Select repository: ${var.github_owner}/${var.repository_name}
    
    6. Configure:
       - Name: react-chatbot
       - Environment: Node
       - Build Command: npm run build
       - Start Command: npm run start
       - Plan: Free or Starter
    
    7. Click "Create Web Service"
    
    8. Wait 2-3 minutes for deployment
    
    9. Your app: https://react-chatbot.onrender.com
    
    ========================================
  EOT
}

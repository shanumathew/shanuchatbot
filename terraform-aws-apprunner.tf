terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "react-chatbot"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "ecr_image_tag" {
  description = "ECR image tag"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "CPU units"
  type        = number
  default     = 1024
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 2048
}

# Data source: Current AWS account
data "aws_caller_identity" "current" {}

# ECR Repository
resource "aws_ecr_repository" "chatbot" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.app_name
    Environment = var.environment
  }
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "chatbot" {
  repository = aws_ecr_repository.chatbot.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# IAM Role for AppRunner
resource "aws_iam_role" "apprunner" {
  name = "${var.app_name}-apprunner-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apprunner.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policy for ECR access
resource "aws_iam_role_policy_attachment" "apprunner_ecr" {
  role       = aws_iam_role.apprunner.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAppRunnerServiceRoleForECRAccess"
}

# CloudWatch Logs policy
resource "aws_iam_role_policy" "apprunner_logs" {
  name = "${var.app_name}-apprunner-logs"
  role = aws_iam_role.apprunner.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# AppRunner Service
resource "aws_apprunner_service" "chatbot" {
  service_name = var.app_name

  source_configuration {
    image_repository {
      image_identifier      = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${aws_ecr_repository.chatbot.name}:${var.ecr_image_tag}"
      image_repository_type = "ECR"

      image_configuration {
        port = var.container_port
      }
    }

    auto_deployments_enabled = true
  }

  instance_configuration {
    cpu               = var.cpu
    memory            = var.memory
    instance_role_arn = aws_iam_role.apprunner.arn
  }

  health_check_configuration {
    protocol            = "TCP"
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 1
    unhealthy_threshold = 5
  }

  tags = {
    Name        = var.app_name
    Environment = var.environment
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "chatbot" {
  name              = "/aws/apprunner/${var.app_name}"
  retention_in_days = 30

  tags = {
    Name        = var.app_name
    Environment = var.environment
  }
}

# CloudWatch Alarm - CPU
resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "${var.app_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/AppRunner"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors CPU utilization"

  dimensions = {
    ServiceArn = aws_apprunner_service.chatbot.arn
  }
}

# CloudWatch Alarm - Memory
resource "aws_cloudwatch_metric_alarm" "memory" {
  alarm_name          = "${var.app_name}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/AppRunner"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This alarm monitors memory utilization"

  dimensions = {
    ServiceArn = aws_apprunner_service.chatbot.arn
  }
}

# Outputs
output "service_url" {
  description = "AppRunner Service URL"
  value       = aws_apprunner_service.chatbot.service_url
}

output "ecr_repository_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.chatbot.repository_url
}

output "service_arn" {
  description = "AppRunner Service ARN"
  value       = aws_apprunner_service.chatbot.arn
}

output "log_group" {
  description = "CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.chatbot.name
}

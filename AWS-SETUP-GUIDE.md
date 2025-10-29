# AWS Deployment Setup Guide

## 🚀 Prerequisites

- AWS Account
- AWS CLI installed (`aws --version`)
- Docker installed
- GitHub account with your repository

## 📋 Step 1: AWS CLI Setup

### Install AWS CLI

**Windows (PowerShell)**:
```powershell
# Using Chocolatey
choco install awscli

# Or download from AWS
# https://aws.amazon.com/cli/
```

### Configure AWS CLI

```bash
aws configure
```

When prompted, enter:
```
AWS Access Key ID: [Your Access Key]
AWS Secret Access Key: [Your Secret Key]
Default region name: us-east-1
Default output format: json
```

### Get AWS Credentials

1. Go to [AWS Console](https://console.aws.amazon.com)
2. Navigate to **IAM → Users → Your User**
3. Click **Security credentials** tab
4. Create access key:
   - Click **Create access key**
   - Choose **Command Line Interface (CLI)**
   - Accept terms and click **Create**
   - Download CSV file (Save securely!)

### Verify AWS CLI

```bash
aws sts get-caller-identity
```

Should show your AWS account info.

---

## 🐳 Step 2: AWS Elastic Container Registry (ECR)

### Create ECR Repository

```bash
# Set variables
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO_NAME=react-chatbot

# Create repository
aws ecr create-repository \
  --repository-name $REPO_NAME \
  --region $AWS_REGION

# Output example:
# {
#   "repository": {
#     "repositoryArn": "arn:aws:ecr:us-east-1:123456789:repository/react-chatbot",
#     "registryId": "123456789",
#     "repositoryName": "react-chatbot",
#     "repositoryUri": "123456789.dkr.ecr.us-east-1.amazonaws.com/react-chatbot"
#   }
# }
```

### Login to ECR

```bash
# Get login token
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Success: Login Succeeded
```

---

## 🏗️ Step 3: Push Docker Image to ECR

### Build and Tag Image

```bash
# Build image
docker build -t react-chatbot:latest .

# Tag for ECR
docker tag react-chatbot:latest \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/react-chatbot:latest

# Push to ECR
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/react-chatbot:latest
```

### Verify Image in ECR

```bash
aws ecr describe-images \
  --repository-name $REPO_NAME \
  --region $AWS_REGION
```

---

## ☁️ Step 4: Deploy to AWS AppRunner (Easiest)

### Create AppRunner Service

```bash
# Using AWS CLI
aws apprunner create-service \
  --service-name react-chatbot \
  --source-configuration '
  {
    "ImageRepository": {
      "ImageIdentifier": "'$AWS_ACCOUNT_ID'.dkr.ecr.'$AWS_REGION'.amazonaws.com/react-chatbot:latest",
      "ImageRepositoryType": "ECR",
      "ImageConfiguration": {
        "Port": "3000"
      }
    }
  }' \
  --instance-configuration 'CpuUnits=1024,MemoryUnits=2048' \
  --region $AWS_REGION
```

### Or Use AWS Console

1. Go to **AWS AppRunner**
2. Click **Create service**
3. Select **Container registry source**
4. Choose **ECR**
5. Select repository: `react-chatbot`
6. Select image tag: `latest`
7. Set port: `3000`
8. Configure:
   - **CPU**: 1 vCPU
   - **Memory**: 2 GB
   - **Instances**: 1
9. Click **Create and deploy**

### Monitor Deployment

```bash
# Get service status
aws apprunner describe-service \
  --service-arn arn:aws:apprunner:$AWS_REGION:$AWS_ACCOUNT_ID:service/react-chatbot \
  --region $AWS_REGION

# Get service URL
aws apprunner describe-service \
  --service-arn arn:aws:apprunner:$AWS_REGION:$AWS_ACCOUNT_ID:service/react-chatbot \
  --query 'Service.ServiceUrl' \
  --output text
```

### Access Your Chatbot

Once deployment is complete (status: RUNNING):
```
https://xxxxxxxxxxxx.us-east-1.apprunner.amazonaws.com
```

---

## 🎯 Step 5: Alternative - Deploy to ECS + Fargate

### Create ECS Cluster

```bash
# Create cluster
aws ecs create-cluster \
  --cluster-name react-chatbot-cluster \
  --region $AWS_REGION
```

### Create IAM Role for ECS Tasks

```bash
# Create trust policy
cat > ecs-task-trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create role
aws iam create-role \
  --role-name ecsTaskRole \
  --assume-role-policy-document file://ecs-task-trust-policy.json

# Attach policy
aws iam attach-role-policy \
  --role-name ecsTaskRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

### Register Task Definition

```bash
# Create task definition
cat > ecs-task-definition.json << 'EOF'
{
  "family": "react-chatbot-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [
    {
      "name": "react-chatbot",
      "image": "AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/react-chatbot:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/react-chatbot",
          "awslogs-region": "AWS_REGION",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ],
  "executionRoleArn": "arn:aws:iam::AWS_ACCOUNT_ID:role/ecsTaskRole"
}
EOF

# Replace placeholders
sed -i "s/AWS_ACCOUNT_ID/$AWS_ACCOUNT_ID/g" ecs-task-definition.json
sed -i "s/AWS_REGION/$AWS_REGION/g" ecs-task-definition.json

# Register
aws ecs register-task-definition \
  --cli-input-json file://ecs-task-definition.json
```

### Create ECS Service

```bash
# Get VPC and Subnets
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --query 'Vpcs[0].VpcId' \
  --output text)

SUBNETS=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'Subnets[0:2].SubnetId' \
  --output text)

# Create service
aws ecs create-service \
  --cluster react-chatbot-cluster \
  --service-name react-chatbot-service \
  --task-definition react-chatbot-task:1 \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNETS],assignPublicIp=ENABLED}" \
  --region $AWS_REGION
```

---

## 🌐 Step 6: Set Up Application Load Balancer (ALB)

### Create Security Group

```bash
# Create security group
SG_ID=$(aws ec2 create-security-group \
  --group-name react-chatbot-sg \
  --description "Security group for React Chatbot" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

# Allow HTTP
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# Allow HTTPS
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0

# Allow 3000
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 3000 \
  --cidr 0.0.0.0/0
```

### Create Load Balancer

```bash
# Get subnets for ALB
SUBNET_IDS=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'Subnets[0:2].SubnetId' \
  --output text | tr '\t' ',')

# Create ALB
ALB_ARN=$(aws elbv2 create-load-balancer \
  --name react-chatbot-alb \
  --subnets $SUBNET_IDS \
  --security-groups $SG_ID \
  --scheme internet-facing \
  --type application \
  --query 'LoadBalancers[0].LoadBalancerArn' \
  --output text)

echo "ALB ARN: $ALB_ARN"
```

---

## 🔒 Step 7: Set Up SSL Certificate (Optional)

### Request Certificate via AWS Certificate Manager

```bash
# Request certificate
CERT_ARN=$(aws acm request-certificate \
  --domain-name your-domain.com \
  --validation-method DNS \
  --query 'CertificateArn' \
  --output text)

echo "Certificate ARN: $CERT_ARN"
```

Then verify domain ownership through DNS records.

---

## 📊 Step 8: Configure Auto Scaling (Optional)

### For ECS Service

```bash
# Register scalable target
aws application-autoscaling register-scalable-target \
  --service-namespace ecs \
  --resource-id service/react-chatbot-cluster/react-chatbot-service \
  --scalable-dimension ecs:service:DesiredCount \
  --min-capacity 1 \
  --max-capacity 3 \
  --region $AWS_REGION

# Create scaling policy
aws application-autoscaling put-scaling-policy \
  --policy-name react-chatbot-cpu-scaling \
  --service-namespace ecs \
  --resource-id service/react-chatbot-cluster/react-chatbot-service \
  --scalable-dimension ecs:service:DesiredCount \
  --policy-type TargetTrackingScaling \
  --target-tracking-scaling-policy-configuration '{
    "TargetValue": 70.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
    },
    "ScaleOutCooldown": 60,
    "ScaleInCooldown": 300
  }' \
  --region $AWS_REGION
```

---

## 📝 Step 9: Environment Variables and Configuration

### Create Parameter Store Configuration

```bash
# Store API configuration
aws ssm put-parameter \
  --name /react-chatbot/node-env \
  --value "production" \
  --type "String" \
  --overwrite

# Store other settings
aws ssm put-parameter \
  --name /react-chatbot/app-title \
  --value "React Chatbot - AWS Hosted" \
  --type "String" \
  --overwrite
```

---

## 📚 Step 10: Monitoring and Logging

### Enable CloudWatch Logs

```bash
# Create log group
aws logs create-log-group \
  --log-group-name /ecs/react-chatbot

# Create log stream
aws logs create-log-stream \
  --log-group-name /ecs/react-chatbot \
  --log-stream-name ecs/react-chatbot
```

### View Logs

```bash
# Stream logs in real-time
aws logs tail /ecs/react-chatbot --follow
```

### Set Up CloudWatch Alarms

```bash
# CPU alarm
aws cloudwatch put-metric-alarm \
  --alarm-name react-chatbot-cpu-high \
  --alarm-description "Alert when CPU is high" \
  --metric-name CPUUtilization \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1
```

---

## 🔄 Step 11: GitHub Actions Integration

### Add GitHub Secrets

1. Go to GitHub repository → **Settings → Secrets and variables → Actions**
2. Add secrets:

```
AWS_ACCESS_KEY_ID: [Your Access Key]
AWS_SECRET_ACCESS_KEY: [Your Secret Key]
AWS_REGION: us-east-1
```

### Add GitHub Variables

1. Go to **Settings → Secrets and variables → Variables**
2. Add variables:

```
AWS_ACCOUNT_ID: 123456789
ECR_REPOSITORY: react-chatbot
```

---

## 🧹 Step 12: Cleanup (If Needed)

### Delete Resources

```bash
# Delete AppRunner service
aws apprunner delete-service \
  --service-arn arn:aws:apprunner:$AWS_REGION:$AWS_ACCOUNT_ID:service/react-chatbot

# Delete ECR repository
aws ecr delete-repository \
  --repository-name react-chatbot \
  --force

# Delete ECS cluster
aws ecs delete-cluster \
  --cluster react-chatbot-cluster

# Delete load balancer
aws elbv2 delete-load-balancer \
  --load-balancer-arn $ALB_ARN
```

---

## 📊 Cost Estimation

### AppRunner (Recommended for simplicity)
- Compute: ~$1.305 per day (running)
- Data transfer: $0.01 per GB
- Estimate: **$30-50/month**

### ECS on Fargate
- Compute: ~$0.044 per vCPU-hour + $0.0044 per GB-hour
- With 1 vCPU, 2GB memory: ~$35-50/month
- Data transfer: $0.01 per GB

### Cost Optimization Tips
1. Stop service when not in use
2. Use auto-scaling (scale down to 0)
3. Use Spot instances (80% cheaper)
4. Choose smaller instance sizes
5. Set up budget alerts

---

## ✅ Deployment Checklist

- [ ] AWS Account created
- [ ] AWS CLI installed and configured
- [ ] ECR repository created
- [ ] Docker image built and pushed
- [ ] AppRunner service created
- [ ] Service status shows RUNNING
- [ ] Can access service URL
- [ ] GitHub secrets configured
- [ ] CloudWatch logs enabled
- [ ] Auto-scaling configured (optional)

---

## 🎯 Next Steps

1. **Monitor your service**: `aws apprunner describe-service ...`
2. **View logs**: Check CloudWatch
3. **Set up domain**: Point custom domain to service
4. **Enable SSL**: Attach certificate to ALB
5. **Automate updates**: Push to GitHub → Deploy automatically

---

## 🆘 Troubleshooting

### Service stuck in PROVISIONING

```bash
# Wait or restart
aws apprunner start-deployment \
  --service-arn arn:aws:apprunner:$AWS_REGION:$AWS_ACCOUNT_ID:service/react-chatbot
```

### Can't access service

1. Check security group rules
2. Verify port 3000 is exposed
3. Check CloudWatch logs for errors

### High costs

1. Stop service when not needed
2. Use auto-scaling to scale down
3. Check CloudWatch for resource usage

---

For more info, see [AWS Documentation](https://docs.aws.amazon.com/)

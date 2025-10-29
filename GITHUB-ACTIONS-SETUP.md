# GitHub Actions Setup Guide

## 🚀 Quick Start

Your React Chatbot project now includes complete CI/CD workflows for GitHub Actions!

## 📁 Workflow Files Created

Located in `.github/workflows/`:

```
.github/workflows/
├── build-and-deploy.yml      # Main CI/CD pipeline
├── docker-hub-push.yml       # Push to Docker Hub
├── deploy-aws.yml            # AWS deployment
├── deploy-kubernetes.yml     # Kubernetes deployment
├── code-quality.yml          # Code quality & security
├── release.yml               # GitHub releases
├── manual-deploy.yml         # Manual deployment
└── README.md                 # Detailed documentation
```

## ⚙️ Setup Steps

### Step 1: Configure Secrets

1. Go to your GitHub repository
2. Navigate to **Settings → Secrets and variables → Actions**
3. Click **New repository secret**

Add secrets based on your deployment targets:

#### For Docker Hub (Optional)
```
DOCKER_USERNAME: your-docker-hub-username
DOCKER_PASSWORD: your-docker-hub-personal-token
```

Get Docker Hub token:
1. Docker Hub → Account Settings → Security
2. Create Personal Access Token
3. Copy token to DOCKER_PASSWORD secret

#### For AWS Deployment (Optional)
```
AWS_ACCESS_KEY_ID: your-aws-access-key
AWS_SECRET_ACCESS_KEY: your-aws-secret-key
```

#### For Kubernetes (Optional)
```
KUBE_CONFIG_DATA: (base64 encoded)
```

To encode kubeconfig:
```bash
cat ~/.kube/config | base64
```

#### For Slack Notifications (Optional)
```
SLACK_WEBHOOK_URL: your-slack-webhook-url
```

### Step 2: Configure Variables

1. Go to **Settings → Secrets and variables → Variables**
2. Click **New repository variable**

Add variables:

```
AWS_REGION: us-east-1
ECS_CLUSTER: my-cluster
ECS_SERVICE: react-chatbot
```

### Step 3: Enable Workflows

Workflows are enabled by default. To verify:

1. Go to **Actions** tab
2. Select each workflow
3. Ensure "Enable workflow" is shown (not disabled)

## 📊 Available Workflows

### 1. Build and Deploy (Main Pipeline)
- **Triggers**: Push to main/master/develop, Pull Requests
- **Actions**: Build, lint, Docker build, push to GHCR
- **No configuration needed** - Works automatically!

### 2. Docker Hub Push
- **Triggers**: Push to main/master or git tag
- **Requirements**: `DOCKER_USERNAME`, `DOCKER_PASSWORD`
- **Actions**: Build and push image to Docker Hub

### 3. AWS Deployment
- **Triggers**: Push to main/master or git tag
- **Requirements**: AWS credentials
- **Options**: ECS or AppRunner

### 4. Kubernetes Deployment
- **Triggers**: Push to main/master or git tag
- **Requirements**: `KUBE_CONFIG_DATA`
- **Actions**: Build, push to GHCR, update deployment

### 5. Code Quality & Security
- **Triggers**: All push/PR events
- **Actions**: Linting, security scanning, dependency check
- **No configuration needed** - Works automatically!

### 6. Release Workflow
- **Triggers**: Git tags (v*)
- **Actions**: Create release, build assets, tag Docker image
- **Example**: `git tag v1.0.0 && git push origin v1.0.0`

### 7. Manual Deploy
- **Triggers**: Manual via Actions tab
- **Actions**: Deploy to staging/production
- **Requirements**: Appropriate credentials

## 🔄 How to Use

### Automatic Builds (No Action Needed)

Just push to repository:

```bash
git add .
git commit -m "Update chatbot"
git push origin main
```

✅ Automatically triggers:
- Code linting
- Build application
- Build Docker image
- Push to GHCR
- Security scans

### Create a Release

Create and push a git tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

✅ Automatically triggers:
- Build Docker image
- Tag with version
- Push to registries
- Create GitHub release
- Generate release notes

### Manual Deployment

1. Go to **Actions** tab
2. Select **"Manual Deploy"** workflow
3. Click **"Run workflow"**
4. Select environment (staging/production)
5. Enter version tag
6. Click **"Run workflow"**

## 📈 Monitor Workflows

### View Workflow Runs

1. **Actions** tab
2. Select workflow name
3. View run details

### Check Logs

1. Click on a workflow run
2. Select the job
3. Expand steps to view logs

### Status Badges

Add to your README.md:

```markdown
![Build Status](https://github.com/shanumathew/shanuchatbot/workflows/Build%20and%20Deploy/badge.svg)
```

## 🔐 Security Best Practices

1. ✅ **Use Secrets** for all credentials
2. ✅ **Rotate secrets** regularly
3. ✅ **Use least privilege** for IAM roles
4. ✅ **Review logs** for sensitive data
5. ✅ **Enable branch protection** rules
6. ✅ **Require status checks** before merge

### Recommended Branch Protection Rules

Settings → Branches → Add rule:

```
Branch name pattern: main

Require status checks:
☑️ build-and-deploy
☑️ code-quality

Dismiss stale PR approvals: ✓
Require up to date branch: ✓
```

## 🚢 Deployment Options

### Option 1: Docker Hub Only

Requirements:
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`

Workflows to enable:
- `build-and-deploy.yml`
- `docker-hub-push.yml`

### Option 2: AWS Only

Requirements:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- Variables: AWS_REGION, ECS_CLUSTER, ECS_SERVICE

Workflows to enable:
- `build-and-deploy.yml`
- `deploy-aws.yml`

### Option 3: Kubernetes Only

Requirements:
- `KUBE_CONFIG_DATA` (base64 encoded)

Workflows to enable:
- `build-and-deploy.yml`
- `deploy-kubernetes.yml`

### Option 4: All Deployment Options

Configure all secrets and variables above.

All workflows will run and deploy to all configured targets.

## 📝 Example Secrets Configuration

```
# Docker Hub
DOCKER_USERNAME: your-username
DOCKER_PASSWORD: dckr_pat_xxxxxxxxxxxx

# AWS
AWS_ACCESS_KEY_ID: AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY

# Kubernetes
KUBE_CONFIG_DATA: <base64-encoded-kubeconfig>

# Notifications
SLACK_WEBHOOK_URL: https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXX
```

## 🐛 Troubleshooting

### Workflow Not Running

**Issue**: Workflow file exists but not running

**Solution**:
1. Verify YAML syntax is correct
2. Check trigger conditions match
3. Ensure file is in `.github/workflows/`
4. Check if workflow is disabled

### Build Failure

**Issue**: Build job fails

**Solution**:
1. Check workflow logs for error
2. Verify dependencies are installed
3. Check TypeScript compilation
4. Review build output

### Deployment Failure

**Issue**: Deployment step fails

**Solution**:
1. Verify secrets are configured
2. Check credentials have permissions
3. Verify target service exists
4. Check network connectivity

### Secret Not Found

**Issue**: "Secret not found" error

**Solution**:
1. Go to Settings → Secrets and variables → Actions
2. Verify secret name exactly matches
3. Check secret has a value
4. Secrets are case-sensitive

## 📊 Workflow Matrix

| Workflow | Trigger | Docker | AWS | K8s | Manual |
|----------|---------|--------|-----|-----|--------|
| build-and-deploy | Push/PR | ✅ | - | - | - |
| docker-hub-push | Tag/main | ✅ | - | - | - |
| deploy-aws | Tag/main | - | ✅ | - | - |
| deploy-kubernetes | Tag/main | - | - | ✅ | - |
| code-quality | Push/PR | - | - | - | - |
| release | Tag | ✅ | - | - | - |
| manual-deploy | Manual | - | ✅ | ✅ | ✅ |

## 🎯 Next Steps

1. **Add secrets** for your deployment target
2. **Configure variables** for AWS/K8s (if needed)
3. **Test workflow** by pushing to main branch
4. **Monitor run** in Actions tab
5. **Set up notifications** for deployment status
6. **Enable branch protection** rules

## 📚 Resources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Docker Build Action](https://github.com/docker/build-push-action)
- [AWS Actions](https://github.com/aws-actions)
- [Kubernetes Actions](https://github.com/marketplace/actions/kubernetes-action)

## ✅ Verification Checklist

- [ ] Workflows files created in `.github/workflows/`
- [ ] GitHub repository secrets configured (if needed)
- [ ] GitHub variables configured (if needed)
- [ ] First push to main triggers build-and-deploy
- [ ] Code quality scan completes
- [ ] Docker image builds successfully
- [ ] Workflows appear in Actions tab
- [ ] Logs are viewable for debugging

## 🎉 You're Ready!

Your GitHub Actions CI/CD pipeline is now configured and ready to use!

**Start using it**:
```bash
git push origin main
```

Check the **Actions** tab to see your first automated build! 🚀

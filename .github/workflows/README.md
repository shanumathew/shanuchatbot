# GitHub Actions CI/CD Workflows

This directory contains GitHub Actions workflows for automated building, testing, and deployment of the React Chatbot.

## 📁 Workflow Files

### 1. `build-and-deploy.yml` - Main CI/CD Pipeline
**Trigger**: Push to `main`, `master`, `develop` or Pull Request

**Jobs**:
- **build**: Build application and Docker image
  - Lint code
  - Build React app
  - Build Docker image
  - Push to GitHub Container Registry (GHCR)
- **test**: Run tests (optional)
- **deploy**: Deployment notifications
- **notify**: Slack notifications (optional)

**Secrets Required**:
- `SLACK_WEBHOOK_URL` (optional)

---

### 2. `docker-hub-push.yml` - Push to Docker Hub
**Trigger**: Push to `main`/`master` or tag (`v*`)

**Actions**:
- Build Docker image
- Push to Docker Hub registry
- Update Docker Hub repository description

**Secrets Required**:
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`

**Environment Variables**:
```
DOCKER_REPO: your-username/react-chatbot
```

---

### 3. `deploy-aws.yml` - Deploy to AWS
**Trigger**: Push to `main`/`master` or tag

**Deployment Options**:
1. **ECS** (Elastic Container Service)
   - Push image to ECR
   - Update ECS service
   
2. **AppRunner** (Serverless)
   - Push image to ECR
   - Start AppRunner deployment

**Secrets Required**:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**Variables Required**:
- `AWS_REGION` (default: us-east-1)
- `ECS_CLUSTER` (if using ECS)
- `ECS_SERVICE` (if using ECS)
- `APPRUNNER_SERVICE_ARN` (if using AppRunner)

---

### 4. `deploy-kubernetes.yml` - Deploy to Kubernetes
**Trigger**: Push to `main`/`master` or tag

**Actions**:
- Build Docker image
- Push to GHCR
- Update Kubernetes deployment
- Verify rollout status

**Secrets Required**:
- `KUBE_CONFIG_DATA` (base64 encoded kubeconfig)

**Namespace**: `production` (configurable)

---

### 5. `code-quality.yml` - Code Quality & Security
**Trigger**: Push or Pull Request

**Jobs**:
- **quality**: Code quality checks
  - ESLint
  - Build verification
  - SonarCloud analysis (optional)
  
- **security**: Security scanning
  - npm audit
  - Snyk scanning (optional)
  - Trivy Docker vulnerability scan
  
- **dependency-check**: Dependency management
  - Check outdated packages
  - Generate SBOM

**Secrets Required** (optional):
- `SONAR_TOKEN` (SonarCloud)
- `SNYK_TOKEN` (Snyk)

---

### 6. `release.yml` - Create Release
**Trigger**: Git tag (`v*`)

**Actions**:
- Build application
- Build and push Docker image
- Create GitHub Release
- Generate release notes
- Publish assets

**Outputs**:
- Docker image tagged with version
- GitHub Release with artifacts

---

### 7. `manual-deploy.yml` - Manual Deployment
**Trigger**: Workflow dispatch (manual trigger)

**Inputs**:
- `environment`: staging or production
- `version`: Docker image tag (default: latest)

**Deployment Targets**:
1. AWS AppRunner
2. Kubernetes cluster
3. Docker Compose (via SSH)

**Secrets Required** (at least one):
- AWS credentials
- `KUBE_CONFIG_DATA`
- `DEPLOY_HOST`, `DEPLOY_USER`, `DEPLOY_PRIVATE_KEY`

---

## 🔐 Required Secrets Setup

### GitHub Secrets Configuration

1. Go to: Repository → Settings → Secrets and variables → Actions

2. Add the following secrets based on your deployment target:

#### For Docker Hub Push
```
DOCKER_USERNAME: your-docker-hub-username
DOCKER_PASSWORD: your-docker-hub-token
```

#### For AWS Deployment
```
AWS_ACCESS_KEY_ID: your-access-key-id
AWS_SECRET_ACCESS_KEY: your-secret-access-key
```

#### For Kubernetes Deployment
```
KUBE_CONFIG_DATA: (base64 encoded kubeconfig)
# Get kubeconfig: cat ~/.kube/config | base64
```

#### For SSH Deployment (Docker Compose)
```
DEPLOY_HOST: your-server-ip-or-domain
DEPLOY_USER: your-ssh-user
DEPLOY_PRIVATE_KEY: your-private-key
```

#### For Notifications (optional)
```
SLACK_WEBHOOK_URL: your-slack-webhook-url
```

---

## 📋 Repository Variables Setup

1. Go to: Repository → Settings → Secrets and variables → Variables

2. Add variables for your configuration:

```
AWS_REGION: us-east-1
ECS_CLUSTER: my-cluster
ECS_SERVICE: react-chatbot
APPRUNNER_SERVICE_ARN: arn:aws:apprunner:...
```

---

## 🚀 Workflow Triggers

### Automatic Triggers

| Event | Workflows Triggered |
|-------|-------------------|
| Push to main | build-and-deploy, docker-hub-push, deploy-aws, deploy-kubernetes, code-quality |
| Push to develop | build-and-deploy, code-quality |
| Pull Request | build-and-deploy, code-quality |
| Git tag (v*) | release, docker-hub-push, deploy-aws, deploy-kubernetes |

### Manual Triggers

- **manual-deploy.yml**: Click "Run workflow" on the Actions tab

---

## 📊 Workflow Status Badges

Add these to your README.md:

```markdown
![Build and Deploy](https://github.com/YOUR_USERNAME/react-chatbot/workflows/Build%20and%20Deploy/badge.svg)
![Docker Hub Push](https://github.com/YOUR_USERNAME/react-chatbot/workflows/Push%20to%20Docker%20Hub/badge.svg)
![Code Quality](https://github.com/YOUR_USERNAME/react-chatbot/workflows/Code%20Quality%20%26%20Security/badge.svg)
```

---

## 🔄 Workflow Examples

### Example 1: Push to main branch

```bash
git add .
git commit -m "Update chatbot features"
git push origin main
```

**Result**: 
- ✅ Code linting
- ✅ Build application
- ✅ Build Docker image
- ✅ Push to GHCR
- ✅ Run security scans
- ✅ Deploy to AWS/Kubernetes (if configured)

### Example 2: Create a release

```bash
git tag v1.0.0
git push origin v1.0.0
```

**Result**:
- ✅ Build Docker image
- ✅ Tag with version number
- ✅ Push to Docker Hub and GHCR
- ✅ Create GitHub Release
- ✅ Generate release notes

### Example 3: Manual deployment

1. Go to Repository → Actions
2. Select "Manual Deploy" workflow
3. Click "Run workflow"
4. Select environment (staging/production)
5. Enter version tag (e.g., latest, v1.0.0)
6. Click "Run workflow"

---

## 📈 Monitoring Workflows

### View Workflow Runs

1. Repository → Actions
2. Select workflow
3. View run details and logs

### Workflow Status

- **Success** ✅
- **Failure** ❌
- **Cancelled** ⏸️
- **In Progress** ⏳

### Check Logs

Click on a workflow run → Select job → View logs

---

## 🛠️ Customization

### Edit Workflows

Workflows are stored in `.github/workflows/`

Example modification - Change Docker registry:

```yaml
# In build-and-deploy.yml
env:
  REGISTRY: docker.io  # Change from ghcr.io to docker.io
  IMAGE_NAME: your-username/react-chatbot
```

### Add New Workflow

1. Create new `.yml` file in `.github/workflows/`
2. Define trigger events
3. Add jobs and steps
4. Commit and push

Example template:

```yaml
name: My Workflow

on:
  push:
    branches: [main]

jobs:
  my-job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: echo "Hello World"
```

---

## 🐛 Troubleshooting

### Workflow Not Running

- [ ] Check workflow is enabled: Actions → Workflow → Enable/Disable
- [ ] Verify file location: `.github/workflows/filename.yml`
- [ ] Check YAML syntax (spaces, indentation)
- [ ] Verify trigger conditions

### Build Failures

- [ ] Check logs: Actions → Workflow run → Job logs
- [ ] Verify secrets are configured
- [ ] Check environment variables
- [ ] Verify file paths

### Docker Push Failures

- [ ] Verify Docker credentials
- [ ] Check registry is accessible
- [ ] Verify image name format
- [ ] Check tag naming conventions

### Deployment Failures

- [ ] Verify deployment credentials (AWS, Kube, SSH)
- [ ] Check target service/cluster exists
- [ ] Verify network connectivity
- [ ] Check sufficient permissions

---

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Actions Security Best Practices](https://docs.github.com/en/actions/security-guides)
- [Docker GitHub Action](https://github.com/docker/build-push-action)
- [Kubernetes GitHub Actions](https://github.com/marketplace/actions/kubernetes-action)
- [AWS GitHub Actions](https://github.com/aws-actions)

---

## 🎯 Best Practices

1. **Use Secrets**: Never commit credentials or API keys
2. **Separate Concerns**: Different workflows for different purposes
3. **Test First**: Run tests before deployment
4. **Version Tags**: Use semantic versioning (v1.0.0, v1.1.0)
5. **Notifications**: Enable notifications for deployment status
6. **Monitoring**: Monitor workflow runs regularly
7. **Documentation**: Keep README updated with workflow info
8. **Security**: Regularly rotate credentials and update actions

---

## 📞 Support

For issues or questions:
1. Check GitHub Actions logs
2. Review workflow configuration
3. Verify secrets and variables
4. Check external service status
5. Open GitHub issue for help

---

**Your CI/CD pipeline is ready! 🚀**

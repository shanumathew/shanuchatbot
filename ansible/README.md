# Ansible Configuration for React Chatbot

Automate Docker builds, image tagging, and pushing to Azure/AWS registries.

---

## 📦 Installation

Ansible is already installed. Verify:

```bash
ansible --version
```

---

## 📁 Files

- **`inventory.ini`** - Define hosts and variables
- **`main.yml`** - Main deployment playbook
- **`docker-build-push.yml`** - Docker build and push tasks
- **`azure-container-manage.yml`** - Azure container management

---

## 🚀 Usage

### Build Docker Image
```bash
ansible-playbook ansible/main.yml --tags build
```

### Tag Images (Azure & AWS)
```bash
ansible-playbook ansible/main.yml --tags tag
```

### Push to Registries
```bash
ansible-playbook ansible/main.yml --tags push
```

### Build + Push (Full Pipeline)
```bash
ansible-playbook ansible/main.yml
```

---

## 📊 Manage Azure Container

### View Container Status
```bash
ansible-playbook ansible/azure-container-manage.yml
```

### View Container Logs
```bash
ansible-playbook ansible/azure-container-manage.yml
```

### Restart Container
```bash
ansible-playbook ansible/azure-container-manage.yml --tags restart
```

---

## 📋 Variables

Edit `inventory.ini` to customize:

```ini
[all:vars]
azure_resource_group=react-chatbot-rg
azure_container_name=react-chatbot-aci
azure_registry=shanumathew
azure_image=react-chatbot
azure_image_tag=latest
azure_port=3000
aws_region=ap-south-1
aws_ecr_account=317009750119
aws_ecr_registry=317009750119.dkr.ecr.ap-south-1.amazonaws.com
docker_image=react-chatbot:latest
```

---

## ⚙️ Prerequisites

- ✅ Ansible installed (`pip install ansible`)
- ✅ Docker installed and running
- ✅ AWS CLI configured (for AWS operations)
- ✅ Azure CLI installed (for Azure operations)
- ✅ Logged into Docker, Azure, and AWS

---

## 🔄 Full Deployment Workflow

```bash
# 1. Build Docker image
ansible-playbook ansible/main.yml --tags build

# 2. Tag for registries
ansible-playbook ansible/main.yml --tags tag

# 3. Push to Azure
ansible-playbook ansible/main.yml --tags push

# 4. Create Container Instance in Azure Portal manually

# 5. Check status
ansible-playbook ansible/azure-container-manage.yml

# 6. View logs
ansible-playbook ansible/azure-container-manage.yml
```

---

## 🛠️ Examples

### Run specific playbook
```bash
ansible-playbook ansible/docker-build-push.yml -i ansible/inventory.ini
```

### Run with verbose output
```bash
ansible-playbook ansible/main.yml -vvv
```

### List all tasks
```bash
ansible-playbook ansible/main.yml --list-tasks
```

### Dry run (check mode)
```bash
ansible-playbook ansible/main.yml --check
```

---

## 📊 View Results

After running playbook, Ansible will show:
- ✅ Build status
- ✅ Image tags
- ✅ Push results
- ✅ Container status (if deployed)

---

## 🆘 Troubleshooting

**Ansible command not found:**
```bash
pip install --upgrade ansible
```

**Docker connection error:**
- Make sure Docker is running
- Check docker daemon: `docker ps`

**Azure CLI not found:**
```bash
pip install azure-cli
```

**Authentication errors:**
- `docker login` to registries first
- `az login` for Azure operations
- `aws configure` for AWS operations

---

## 📚 Useful Commands

```bash
# Check Ansible version
ansible --version

# List inventory
ansible-inventory -i ansible/inventory.ini --list

# Run specific task
ansible-playbook ansible/main.yml --tags build -vvv

# Dry run
ansible-playbook ansible/main.yml --check

# View playbook
cat ansible/main.yml
```

---

## ✨ Benefits

✅ Automate Docker builds
✅ Consistent tagging across registries
✅ One-command deployment
✅ Easy to maintain and version control
✅ Repeatable deployments
✅ CI/CD friendly

---

**For more info:** https://docs.ansible.com/

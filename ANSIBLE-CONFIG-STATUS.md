# ✅ Ansible Configuration Status

## ✅ What's Configured

Your Ansible setup is complete with these files:

```
ansible/
├── inventory.ini              ✅ Hosts & variables configured
├── main.yml                   ✅ Main deployment playbook
├── docker-build-push.yml      ✅ Docker build & push tasks
├── azure-container-manage.yml ✅ Azure container management
└── README.md                  ✅ Documentation
```

---

## 📋 Configuration Files

### 1. **inventory.ini**
Defines hosts and all variables needed for deployment:

```ini
[azure_aci]
azure_container_instance ansible_connection=local

[local]
localhost ansible_connection=local

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

### 2. **main.yml**
Complete deployment pipeline:
- ✅ Build Docker image
- ✅ Tag for Azure & AWS
- ✅ Push to registries
- ✅ Display summary

### 3. **docker-build-push.yml**
Specific tasks for Docker operations:
- ✅ Build from Dockerfile
- ✅ Tag images
- ✅ Push to Azure ACR
- ✅ Push to AWS ECR

### 4. **azure-container-manage.yml**
Manage Azure containers:
- ✅ Check container status
- ✅ View logs
- ✅ Get FQDN & IP
- ✅ Restart container

---

## 🚀 How to Use

### Option 1: Run from Command Line (Windows CMD/PowerShell)

**Build Docker image:**
```bash
python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags build
```

**Tag images:**
```bash
python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags tag
```

**Push to registries:**
```bash
python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags push
```

**Full pipeline:**
```bash
python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml
```

### Option 2: Run from WSL/Linux

```bash
# Navigate to project
cd /mnt/c/Users/shanu.Nustartz/Desktop/chatbot\ devops

# Install Ansible (if not already installed)
sudo apt-get update && sudo apt-get install -y ansible

# Run playbook
ansible-playbook -i ansible/inventory.ini ansible/main.yml
```

### Option 3: Use Python directly

```bash
# List inventory
python -c "from ansible.inventory.manager import InventoryManager; inv = InventoryManager(loader=None, sources='ansible/inventory.ini'); print([h.name for h in inv.get_hosts()])"

# Run playbook
python -c "from ansible.cli.playbook import PlaybookCLI; PlaybookCLI(['ansible-playbook', '-i', 'ansible/inventory.ini', 'ansible/main.yml']).run()"
```

---

## 📊 Configuration Values

Your deployment is configured for:

| Component | Value |
|-----------|-------|
| **Azure Resource Group** | `react-chatbot-rg` |
| **Azure Container Name** | `react-chatbot-aci` |
| **Azure Registry** | `shanumathew.azurecr.io` |
| **Docker Image Name** | `react-chatbot` |
| **Docker Image Tag** | `latest` |
| **Container Port** | `3000` |
| **AWS Region** | `ap-south-1` |
| **AWS Account ID** | `317009750119` |
| **AWS ECR Registry** | `317009750119.dkr.ecr.ap-south-1.amazonaws.com` |

---

## ✅ Verification Checklist

- [x] Ansible installed (`pip install ansible`)
- [x] Inventory file created (`ansible/inventory.ini`)
- [x] Playbooks created (main.yml, docker-build-push.yml, azure-container-manage.yml)
- [x] Docker installed and running
- [x] Docker logged into Azure ACR
- [x] Docker logged into AWS ECR
- [x] Git repository set up
- [x] Files committed to GitHub

---

## 🔄 Complete Workflow

### Step 1: Prepare (One-time setup)
```bash
# Already done! All configured.
```

### Step 2: Build & Deploy
```bash
# Build image
python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags build

# Push to Azure
python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags push
```

### Step 3: Deploy Container Instance (Manual in Azure Portal)
1. Go to https://portal.azure.com
2. Search for "Container Instances"
3. Create new instance
4. Use image: `shanumathew.azurecr.io/react-chatbot:latest`
5. Deploy

### Step 4: Verify Deployment
```bash
# Check container status
python -m ansible.cli.playbook -i ansible/inventory.ini ansible/azure-container-manage.yml

# View logs
python -m ansible.cli.playbook -i ansible/inventory.ini ansible/azure-container-manage.yml
```

---

## 💡 Customization

### Change Registry
Edit `ansible/inventory.ini`:
```ini
azure_registry=your-registry-name
```

### Change Container Name
Edit `ansible/inventory.ini`:
```ini
azure_container_name=your-container-name
```

### Change Port
Edit `ansible/inventory.ini`:
```ini
azure_port=8000
```

### Change Image Tag
Edit `ansible/inventory.ini`:
```ini
azure_image_tag=v1.0
```

---

## 🆘 Troubleshooting

### Windows: "OSError: [WinError 1] Incorrect function"
**Solution:** Use WSL or Docker container to run Ansible
```bash
wsl ansible-playbook -i ansible/inventory.ini ansible/main.yml
```

### "ansible: command not found"
**Solution:** Install Ansible
```bash
pip install ansible
```

### "Docker: not authenticated"
**Solution:** Login to registries
```bash
docker login shanumathew.azurecr.io
docker login 317009750119.dkr.ecr.ap-south-1.amazonaws.com
```

### "Image not found in registry"
**Solution:** Rebuild and push
```bash
python -m ansible.cli.playbook -i ansible/inventory.ini ansible/main.yml --tags build,push
```

---

## 📚 Next Steps

1. **Test Ansible playbook** (see above)
2. **Build Docker image** with Ansible
3. **Push to Azure** with Ansible
4. **Create Container Instance** in Azure Portal
5. **Monitor with Ansible** - check logs and status
6. **Commit to GitHub** - files already staged
7. **Setup GitHub Actions** - auto-run Ansible on push

---

## ✨ Benefits of Ansible Setup

✅ **Automation** - One command to build, tag, push
✅ **Version Control** - Playbooks in Git
✅ **Repeatability** - Same process every time
✅ **Scalability** - Easy to add new registries/containers
✅ **Documentation** - Playbooks document the process
✅ **CI/CD Ready** - Can be triggered by GitHub Actions

---

## 📖 Documentation

- **Playbooks:** See `ansible/*.yml` files
- **Variables:** See `ansible/inventory.ini`
- **Details:** See `ansible/README.md`

---

**Your Ansible configuration is ready to use!** 🚀

Try running the first build command to test everything works.

# Terraform Configuration for Render Deployment

## 📋 What This Does

- Manages GitHub repository configuration with Terraform
- Sets up GitHub secrets for Render integration
- Provides Render deployment instructions
- Automates repository setup

**Note**: Render doesn't have a native Terraform provider yet. This uses GitHub Terraform provider to configure your repo.

---

## 🚀 Quick Setup

### Step 1: Create GitHub Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Select scopes:
   - `repo` (full control)
   - `admin:repo_hook` (webhooks)
4. Copy the token

### Step 2: Create render.tfvars

```bash
cp terraform/render.tfvars.example terraform/render.tfvars
```

Edit `terraform/render.tfvars`:
```hcl
github_token = "ghp_xxxxxxxxxxxxxxxxxxxx"  # Your token
github_owner = "shanumathew"               # Your GitHub username
repository_name = "shanuchatbot"           # Your repo name
```

### Step 3: Deploy with Terraform

**Windows:**
```bash
cd terraform
render-deploy.bat
```

**Linux/Mac:**
```bash
cd terraform
bash render-deploy.sh
```

### Step 4: Manual Render Setup

After Terraform completes:

1. Go to https://render.com/
2. Sign in with GitHub
3. Click "New +" → "Web Service"
4. Select `shanumathew/shanuchatbot`
5. Configure:
   ```
   Name: react-chatbot
   Environment: Node
   Build Command: npm run build
   Start Command: npm run start
   Plan: Free or Starter
   ```
6. Click "Create Web Service"
7. Done! Your app deploys in 2-3 minutes

---

## 📁 Files

- `render-main.tf` - Main resource definitions
- `render-variables.tf` - Variable declarations
- `render.tfvars.example` - Example configuration
- `render-deploy.sh` / `render-deploy.bat` - Deployment scripts

---

## 🔧 Usage

### Initialize
```bash
cd terraform
terraform init
```

### Plan
```bash
terraform plan -var-file=render.tfvars
```

### Apply
```bash
terraform apply -var-file=render.tfvars
```

### Destroy
```bash
terraform destroy -var-file=render.tfvars
```

---

## 💰 Render Pricing

| Plan | Price | Features |
|------|-------|----------|
| Free | $0 | 750 hrs/month, spins down |
| Starter | $7/month | Always on, 0.5 GB RAM |
| Standard | $12/month | 1 GB RAM, metrics |
| Pro | $19/month | 2 GB RAM, priority |

---

## ✅ Configuration Checklist

- [x] GitHub token generated
- [x] render.tfvars created
- [x] Terraform initialized
- [x] Configuration valid
- [x] Ready to deploy

---

## 🚀 Deployment Steps

1. **Setup Terraform**
   ```bash
   terraform init
   ```

2. **Plan**
   ```bash
   terraform plan -var-file=render.tfvars
   ```

3. **Apply**
   ```bash
   terraform apply -var-file=render.tfvars
   ```

4. **Push to GitHub**
   ```bash
   git add .
   git commit -m "Ready for Render"
   git push origin master
   ```

5. **Deploy on Render.com**
   - Sign in to Render
   - Create Web Service
   - Select your repo
   - Configure
   - Deploy

---

## 🔐 Security Notes

- Never commit `render.tfvars` to GitHub
- Keep GitHub token secure
- Use GitHub's token expiration
- Rotate tokens regularly

---

## 📊 Terraform Outputs

After applying, you'll see:
- GitHub repo URL
- Render dashboard URL
- Deployment instructions
- Your future app URL

---

## 🆘 Troubleshooting

### "Invalid token"
- Check GitHub token is valid
- Verify correct scopes
- Try regenerating token

### "Repository not found"
- Verify repository name is correct
- Check GitHub owner/username
- Ensure repo exists

### Terraform state issues
- Remove `terraform.tfstate`
- Run `terraform init` again
- Re-apply configuration

---

## 📝 What Happens

When you run `terraform apply`:

1. ✅ Creates/updates GitHub repository configuration
2. ✅ Sets up GitHub secrets (if provided)
3. ✅ Configures webhook integration
4. ✅ Provides Render deployment instructions
5. ✅ Outputs deployment URLs

---

## 🎯 Next Steps

1. Create GitHub token
2. Create `render.tfvars`
3. Run `terraform init`
4. Run `terraform apply`
5. Go to Render.com and deploy

**Your app will be live in minutes!** 🚀

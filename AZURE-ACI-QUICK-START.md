# 🚀 Azure Container Instance - Quick Deploy

## Your Details
- **Registry**: `shanumathew.azurecr.io`
- **Image**: `react-chatbot`
- **Tag**: `latest`
- **Username**: `shanumathew`

---

## Step-by-Step Deployment

### 1️⃣ Go to Azure Portal
Open: https://portal.azure.com

### 2️⃣ Create Container Instance
- Search for **"Container Instances"**
- Click **"Create"**

### 3️⃣ Fill in Basics Tab

| Field | Value |
|-------|-------|
| **Subscription** | Your subscription |
| **Resource group** | `react-chatbot-rg` (create new if needed) |
| **Container name** | `react-chatbot-aci` |
| **Region** | `East US` |
| **Image source** | Azure Container Registry |

### 4️⃣ Fill in Registry Tab

| Field | Value |
|-------|-------|
| **Registry** | `shanumathew` |
| **Image** | `react-chatbot` |
| **Image tag** | `latest` |

### 5️⃣ Fill in Networking Tab

| Field | Value |
|-------|-------|
| **Public IP** | `Enabled` ✅ |
| **DNS name label** | `react-chatbot-shanu` |
| **Port** | `3000` |
| **Protocol** | `TCP` |

### 6️⃣ Review & Create
- Click **"Review + create"**
- Click **"Create"**

### 7️⃣ Wait for Deployment
⏳ Takes 2-3 minutes...

### 8️⃣ Get Your URL
Once deployed:
1. Go to **Container Instances**
2. Click on `react-chatbot-aci`
3. Look for **FQDN** field
4. Your URL: **`http://react-chatbot-shanu.azurecontainer.io:3000`**

---

## ✅ You're Done!

Open your chatbot in browser: 🌐

```
http://react-chatbot-shanu.azurecontainer.io:3000
```

---

## 📊 Monitor & Manage

### View Logs
- Go to Container Instance
- Click **"Logs"** tab
- See real-time output

### Restart Container
- Go to Container Instance
- Click **"Restart"** button

### Stop Container (Save Money)
- Go to Container Instance
- Click **"Stop"** button

### Delete (When Done)
- Go to **Resource Groups**
- Click `react-chatbot-rg`
- Click **"Delete resource group"**
- Type resource group name to confirm

---

## 💰 Costs
- **Container Instances**: ~$40/month
- **Container Registry**: ~$5/month
- **Total**: ~**$45/month**

---

## 🆘 Troubleshooting

**Container won't start?**
- Check **Logs** tab for errors
- Make sure port 3000 is correct in Dockerfile

**Can't access the URL?**
- Wait 2-3 minutes for deployment
- Check FQDN is correct
- Check status is "Running"

**Image not found?**
- Verify registry name: `shanumathew`
- Verify image name: `react-chatbot`
- Verify tag: `latest`

---

**Need help?** Check Azure Portal → Container Instance → Logs for error messages! 📋

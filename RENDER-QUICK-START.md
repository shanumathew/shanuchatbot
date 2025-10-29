# Render Deployment - Quick Start

## ✅ Pre-Deployment Checklist

- [x] **Procfile** - Start command configured
- [x] **package.json** - Build & start scripts added
- [x] **app.json** - App configuration ready
- [x] **render.yaml** - Render config ready
- [x] **Dockerfile** - Container ready (optional)

---

## 🚀 Quick Deployment (5 minutes)

### 1. Commit & Push to GitHub
```bash
git add .
git commit -m "Configure for Render deployment"
git push origin master
```

### 2. Go to Render.com
- https://render.com/
- Click "New +" → "Web Service"
- Select your GitHub repo: `shanumathew/shanuchatbot`

### 3. Configure Service
```
Name: react-chatbot
Environment: Node
Build Command: npm run build
Start Command: npm run start
Plan: Free or Starter
```

### 4. Add Environment Variables (Optional)
```
PORT=3000
NODE_ENV=production
```

### 5. Deploy
- Click "Create Web Service"
- Wait 2-3 minutes
- Done! ✅

---

## 📍 Your App URL

Once deployed: `https://react-chatbot.onrender.com`

---

## 📊 Render Plans

| Feature | Free | Starter | Standard |
|---------|------|---------|----------|
| Price | $0 | $7/month | $12/month |
| Uptime | 750 hrs/month | Always on | Always on |
| RAM | 0.5 GB | 0.5 GB | 1 GB |
| Auto-spindown | Yes | No | No |

**Recommendation**: Start with Free, upgrade to Starter ($7/month) if needed.

---

## 🔄 Redeploy

Every `git push` to master automatically redeploys.

Or manually in Render Dashboard:
- Select service
- Click "Manual Deploy"
- Select commit
- Deploy

---

## 📝 Files Used

- ✅ `Procfile` - Start command
- ✅ `package.json` - Build config
- ✅ `app.json` - App metadata
- ✅ `render.yaml` - Render config
- ✅ `Dockerfile` - Optional Docker support

---

## 💡 Tips

1. **Free tier**: Spins down after 15 mins inactivity (start in 30 secs)
2. **Logs**: Check in Render Dashboard → Logs
3. **Custom domain**: Add in Render Dashboard → Custom Domain
4. **Monitoring**: Enable notifications for deployment events

---

## 🆘 Troubleshooting

**Build fails?**
- Check `npm run build` locally
- Verify `package.json` dependencies

**App won't start?**
- Check logs in Render Dashboard
- Verify `npm run start` works locally

**Port errors?**
- App must listen on PORT from environment (already configured)

---

## ✨ Status

✅ **Ready to deploy!**

All configuration files are ready. Just push to GitHub and create the Render service.

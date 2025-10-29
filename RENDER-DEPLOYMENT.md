# Render Deployment Configuration

## 📋 Prerequisites

1. GitHub account with repository pushed
2. Render account (free tier available): https://render.com/
3. Node.js 18+ (Render will handle this)

---

## 🚀 Step-by-Step Deployment

### Step 1: Push Code to GitHub
```bash
git add .
git commit -m "Ready for Render deployment"
git push origin master
```

### Step 2: Create Render Account
1. Go to https://render.com/
2. Sign up with GitHub account
3. Click "Connect GitHub account"

### Step 3: Create Web Service
1. Go to https://dashboard.render.com/
2. Click "New +" → "Web Service"
3. Select your repository: `shanumathew/shanuchatbot`
4. Fill in:
   - **Name**: `react-chatbot`
   - **Environment**: `Node`
   - **Build Command**: `npm run build`
   - **Start Command**: `npm run start`
   - **Plan**: Free (or Starter paid)

### Step 4: Add Environment Variables
In Render Dashboard → Your Service → Environment:

Add these variables:
```
PORT=3000
NODE_ENV=production
```

If using API key:
```
VITE_API_KEY=your_gemini_api_key
```

### Step 5: Deploy
1. Click "Create Web Service"
2. Render will automatically start deploying
3. Watch the build logs
4. Once deployed, you'll get a URL: `https://react-chatbot.onrender.com`

---

## 📊 Render Pricing

| Plan | Price | Features |
|------|-------|----------|
| **Free** | $0 | 750 hours/month, auto-spins down |
| **Starter** | $7/month | Always on, 0.5 GB RAM |
| **Standard** | $12/month | 1 GB RAM, metrics |
| **Pro** | $19/month | 2 GB RAM, priority support |

---

## ✅ Deployment Configuration Files

The following files are already configured:

- ✅ **`Procfile`** - Start command for Render
- ✅ **`package.json`** - Build & start scripts
- ✅ **`Dockerfile`** - Alternative Docker deployment
- ✅ **`vite.config.ts`** - Build configuration

---

## 🔄 Redeploy After Changes

### Option 1: Automatic (Recommended)
Every push to `master` branch automatically triggers redeploy.

### Option 2: Manual
1. Go to Render Dashboard
2. Select your service
3. Click "Manual Deploy" → "Deploy latest commit"

---

## 🔗 Accessing Your App

Once deployed:
```
https://react-chatbot.onrender.com
```

Or use a custom domain:
1. In Render Dashboard → Custom Domain
2. Add your domain
3. Update DNS records as instructed

---

## 📝 Logs & Monitoring

View logs in Render Dashboard:
1. Select your service
2. Click "Logs" tab
3. See real-time deployment logs

---

## 🚨 Troubleshooting

### Build fails
- Check `npm run build` works locally
- Verify all dependencies in `package.json`
- Check Node version compatibility

### App won't start
- Check `PORT` environment variable
- Verify start command in `Procfile`
- Check logs in Render Dashboard

### Free tier spins down
- Use paid plan (Starter $7/month)
- Or keep accessing app every 15 minutes

---

## 🆘 Common Issues & Fixes

### "Cannot find module"
```bash
# Locally verify
npm install
npm run build
npm run start
```

### Port issues
- Render automatically sets PORT=3000
- Make sure app listens on this port

### Build timeout
- Increase build timeout in Render settings
- Optimize build process

---

## 💡 Pro Tips

1. **Free tier limits**: 750 hours/month (30 days)
2. **Auto spin-down**: Frees up resources after 15 mins inactivity
3. **Backup**: Always keep GitHub repo updated
4. **Monitoring**: Enable Render notifications for deployment events

---

## ✨ What's Ready

✅ Docker support  
✅ Node.js configured  
✅ Build scripts optimized  
✅ Port 3000 configured  
✅ Environment variables ready  

---

## 🎯 Next Steps

1. Push code to GitHub (if not done)
2. Go to https://render.com/
3. Connect GitHub
4. Create Web Service
5. Add environment variables
6. Deploy!

**Your app will be live in 2-3 minutes!** 🚀

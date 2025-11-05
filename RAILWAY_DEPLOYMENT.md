# Railway Deployment Guide - HomeDesign AI

This guide will help you deploy the HomeDesign AI backend and static pages to Railway.

## Prerequisites

- Railway account (sign up at https://railway.app)
- GitHub account (to connect your repository)
- Apple Developer account (for iOS app submission)

## Step 1: Prepare Your Repository

1. **Create a `.gitignore` file in the Backend directory** (if not already present):
```
node_modules/
.env
data/subscribers.json
```

2. **Ensure your `.env` file has the correct Gemini API key**:
```
GEMINI_API_KEY=your_actual_gemini_api_key_here
PORT=3000
NODE_ENV=production
```

3. **Commit all changes** to your repository:
```bash
cd /path/to/HomeDesignAI
git add .
git commit -m "Prepare for Railway deployment"
git push origin main
```

## Step 2: Deploy to Railway

### Option A: Deploy via Railway Dashboard (Recommended)

1. **Go to https://railway.app and sign in**

2. **Create a New Project**:
   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Authorize Railway to access your GitHub account
   - Select your HomeDesignAI repository

3. **Configure the Service**:
   - Railway will auto-detect your Node.js app
   - Root directory: Select `Backend`
   - Start command: `node index.js`

4. **Set Environment Variables**:
   - Click on your service
   - Go to "Variables" tab
   - Add the following variables:
     ```
     GEMINI_API_KEY=your_actual_gemini_api_key
     NODE_ENV=production
     PORT=3000
     ```

5. **Deploy**:
   - Railway will automatically build and deploy
   - Wait for deployment to complete (usually 2-3 minutes)

6. **Get Your Production URL**:
   - Click on "Settings" tab
   - Under "Domains", click "Generate Domain"
   - You'll get a URL like: `https://homedesignai-production.up.railway.app`
   - **SAVE THIS URL** - you'll need it for the iOS app

### Option B: Deploy via Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Navigate to Backend directory
cd Backend

# Initialize Railway project
railway init

# Add environment variables
railway variables set GEMINI_API_KEY=your_api_key
railway variables set NODE_ENV=production

# Deploy
railway up
```

## Step 3: Verify Deployment

1. **Test the Health Endpoint**:
```bash
curl https://your-railway-url.up.railway.app/health
```

Expected response:
```json
{
  "status": "ok",
  "service": "HomeDesign AI Backend",
  "timestamp": "2024-11-05T..."
}
```

2. **Test the Landing Page**:
   - Open: `https://your-railway-url.up.railway.app/`
   - You should see the HomeDesign AI landing page

3. **Test Privacy Policy**:
   - Open: `https://your-railway-url.up.railway.app/privacy`
   - Should display the privacy policy

4. **Test Terms of Service**:
   - Open: `https://your-railway-url.up.railway.app/terms`
   - Should display the terms

## Step 4: Update iOS App with Production URL

1. **Edit APIService.swift**:
```swift
// File: iOS/HomeDesignAI/Services/APIService.swift

private static var baseURL: String {
    #if DEBUG
    return "http://localhost:3000"  // For local testing
    #else
    return "https://your-railway-url.up.railway.app"  // Replace with your Railway URL
    #endif
}
```

2. **Update AboutView.swift** with your Railway URLs:
```swift
// Replace "https://your-railway-app.railway.app" with your actual URL
if let privacyURL = URL(string: "https://your-railway-url.up.railway.app/privacy") {
    // ...
}

if let termsURL = URL(string: "https://your-railway-url.up.railway.app/terms") {
    // ...
}
```

## Step 5: Update Privacy Policy and Terms with Contact Info

1. **Edit public/privacy.html**:
   - Find `[YOUR SUPPORT EMAIL]` and replace with your actual support email
   - Find `[YOUR WEBSITE URL]` and replace with your Railway URL

2. **Edit public/terms.html**:
   - Find `[YOUR SUPPORT EMAIL]` and replace with your actual support email
   - Find `[YOUR WEBSITE URL]` and replace with your Railway URL
   - Find `[YOUR STATE]` and replace with your state (for governing law)

3. **Redeploy** (Railway auto-deploys on git push):
```bash
git add .
git commit -m "Update contact information in legal pages"
git push origin main
```

## Step 6: Test End-to-End

1. **Test Image Generation**:
```bash
# Prepare a base64-encoded test image
# Then test the /generate endpoint
curl -X POST https://your-railway-url.up.railway.app/generate \
  -H "Content-Type: application/json" \
  -d '{
    "image": "base64_encoded_image_here",
    "sceneType": "living_room",
    "style": "classic"
  }'
```

2. **Test Email Subscription**:
```bash
curl -X POST https://your-railway-url.up.railway.app/subscribe \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'
```

Expected response:
```json
{
  "success": true,
  "message": "You're on the list! We'll notify you when the full app launches.",
  "alreadySubscribed": false
}
```

## Step 7: Monitor Your Deployment

1. **View Logs**:
   - In Railway dashboard, click on your service
   - Click "Deployments" tab
   - Click on latest deployment
   - View real-time logs

2. **Set Up Monitoring** (Optional but recommended):
   - Railway provides basic metrics
   - Consider adding:
     - Sentry for error tracking
     - LogRocket for session replay
     - PostHog for analytics

## Common Issues & Solutions

### Issue: 502 Bad Gateway
**Solution**: Check Railway logs. Usually means:
- Backend crashed on startup
- Missing environment variables
- Port binding issue (ensure you use `process.env.PORT`)

### Issue: CORS Errors
**Solution**: Update CORS settings in Backend/index.js:
```javascript
app.use(cors({
  origin: ['https://your-ios-app-domain.com', 'capacitor://localhost'],
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type']
}));
```

### Issue: Images Not Generating
**Solution**:
1. Check Gemini API key is set correctly
2. Verify API key has proper permissions
3. Check Railway logs for specific error messages

### Issue: Static Files Not Serving
**Solution**: Ensure the `public` folder is in the correct location relative to `Backend/index.js`

## Cost Estimate

**Railway Pricing** (as of November 2024):
- **Free Tier**: $5 of usage credit per month
- **Hobby Plan**: $5/month + usage
- **Pro Plan**: $20/month + usage

**Estimated Monthly Costs** (1000 users):
- Backend hosting: ~$5-15/month
- Egress (data transfer): ~$2-5/month
- **Total**: ~$10-20/month (within Hobby plan)

**Note**: Railway charges for:
- Active runtime hours
- Memory usage
- Network egress

## Next Steps

- [ ] Deploy backend to Railway
- [ ] Get production URL
- [ ] Update iOS app with production URL
- [ ] Test all endpoints
- [ ] Update legal pages with contact info
- [ ] Set up monitoring
- [ ] Configure Xcode signing
- [ ] Build and upload to App Store Connect

## Support

If you encounter issues:
1. Check Railway logs first
2. Review Railway documentation: https://docs.railway.app
3. Check Gemini AI API status: https://status.google.com

---

**Good luck with your deployment!** 🚀🎄

# App Store Submission Checklist - HomeDesign AI

Use this checklist to ensure you've completed all required tasks before submitting to the App Store.

## ✅ COMPLETED TASKS

### Legal & Compliance
- [x] **Privacy Policy created** - `/public/privacy.html`
- [x] **Terms of Service created** - `/public/terms.html`
- [x] **Landing page created** - `/public/index.html`
- [x] **About screen added to app** - `iOS/HomeDesignAI/Views/AboutView.swift`
- [x] **Amazon affiliate disclosure** - Added to ResultView and legal pages

### iOS App Configuration
- [x] **App icons generated** - All required sizes (29px to 1024px)
- [x] **ATS security fixed** - Restricted to localhost only (not wide-open)
- [x] **Accessibility labels added** - Main action buttons now VoiceOver accessible
- [x] **Info.plist permissions** - Camera, Photo Library properly configured

### Backend
- [x] **Email subscription endpoint** - `/Backend/routes/subscribe.js` working
- [x] **Static file serving configured** - Backend serves public folder
- [x] **Railway deployment guide** - Complete instructions in `RAILWAY_DEPLOYMENT.md`

---

## 🔄 PENDING TASKS (Must Complete Before Submission)

### 1. Deploy to Railway
**Priority: CRITICAL**
**Status:** Not started

**Steps:**
1. Follow `RAILWAY_DEPLOYMENT.md`
2. Sign up at https://railway.app
3. Deploy Backend folder
4. Set environment variables (GEMINI_API_KEY)
5. Generate domain URL
6. Save URL for next steps

**Expected URL format:** `https://homedesignai-production.up.railway.app`

---

### 2. Update iOS App with Production URLs
**Priority:** CRITICAL
**Status:** Not started
**Depends on:** Railway deployment

**Files to update:**

#### A. APIService.swift
**File:** `iOS/HomeDesignAI/Services/APIService.swift`
**Line:** ~43

**Find:**
```swift
return "https://your-backend-url.com"
```

**Replace with:**
```swift
private static var baseURL: String {
    #if DEBUG
    return "http://localhost:3000"
    #else
    return "https://YOUR-RAILWAY-URL.up.railway.app"  // ⚠️ REPLACE THIS
    #endif
}
```

#### B. AboutView.swift
**File:** `iOS/HomeDesignAI/Views/AboutView.swift`
**Lines:** ~69, ~76

**Find (Line 69):**
```swift
if let privacyURL = URL(string: "https://your-railway-app.railway.app/privacy") {
```

**Replace with:**
```swift
if let privacyURL = URL(string: "https://YOUR-RAILWAY-URL.up.railway.app/privacy") {
```

**Find (Line 76):**
```swift
if let termsURL = URL(string: "https://your-railway-app.railway.app/terms") {
```

**Replace with:**
```swift
if let termsURL = URL(string: "https://YOUR-RAILWAY-URL.up.railway.app/terms") {
```

---

### 3. Update Legal Pages with Contact Information
**Priority:** CRITICAL
**Status:** Not started

**Files to update:**

#### A. Privacy Policy
**File:** `public/privacy.html`

**Find and replace ALL instances of:**
- `[YOUR SUPPORT EMAIL]` → Your actual support email
- `[YOUR WEBSITE URL]` → Your Railway URL

**Locations:**
- Line ~133: Contact section
- Line ~138: Contact section

#### B. Terms of Service
**File:** `public/terms.html`

**Find and replace ALL instances of:**
- `[YOUR SUPPORT EMAIL]` → Your actual support email
- `[YOUR WEBSITE URL]` → Your Railway URL
- `[YOUR STATE]` → Your state (e.g., "California") for governing law

**Locations:**
- Line ~295: Governing Law section
- Line ~325: Contact section
- Line ~330: Contact section

**After updating, redeploy to Railway:**
```bash
git add .
git commit -m "Update contact information"
git push origin main
```

---

### 4. Configure Xcode Signing
**Priority:** CRITICAL
**Status:** Not started

**Steps:**
1. Open Xcode project: `iOS/HomeDesignAI.xcodeproj`
2. Select `HomeDesignAI` target
3. Go to "Signing & Capabilities" tab
4. Select your Apple Developer Team
5. Ensure bundle ID is: `com.homedesign.ai` (or your preference)
6. Enable "Automatically manage signing"
7. Verify provisioning profile is created

**Verification:**
- Build succeeds without signing errors
- Can archive for distribution (Product → Archive)

---

### 5. Test End-to-End Flow
**Priority:** CRITICAL
**Status:** Not started
**Depends on:** Railway deployment, iOS app URL updates

**Test Checklist:**

#### Backend Tests
- [ ] Visit landing page: `https://your-railway-url/`
- [ ] Visit privacy page: `https://your-railway-url/privacy`
- [ ] Visit terms page: `https://your-railway-url/terms`
- [ ] Test health endpoint: `curl https://your-railway-url/health`
- [ ] Test email subscription:
  ```bash
  curl -X POST https://your-railway-url/subscribe \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com"}'
  ```

#### iOS App Tests (on Physical Device)
- [ ] Upload photo from camera
- [ ] Upload photo from library
- [ ] Select scene type
- [ ] Select decoration style
- [ ] Generate decorated image
- [ ] Save image to photo library
- [ ] Share image
- [ ] Tap "Shop the Look" product (opens Safari)
- [ ] Submit email for unlock (if < 10 generations)
- [ ] Verify unlimited generations after email
- [ ] Tap About button → Privacy Policy link
- [ ] Tap About button → Terms of Service link
- [ ] Reset and create new design

---

### 6. Capture App Store Screenshots
**Priority:** CRITICAL
**Status:** Not started

**Required Screenshots:**

#### iPhone (6.5" Display - iPhone 14 Pro Max or similar)
Minimum 3 screenshots, recommended 5:
1. **Welcome/Upload screen** - Shows app intro
2. **Style selection** - Shows decoration options
3. **Result screen** - Before/after or decorated result
4. **Shop the Look** - Product recommendations
5. **About screen** (optional)

**Size:** 1290 x 2796 pixels

#### iPad Pro (12.9" 3rd gen)
Minimum 3 screenshots:
1. **Upload screen**
2. **Style selection**
3. **Result screen**

**Size:** 2048 x 2732 pixels

**How to capture:**
1. Run app on simulator (iPhone 14 Pro Max, iPad Pro 12.9")
2. Navigate to each screen
3. Press `Cmd + S` to save screenshot
4. Screenshots saved to Desktop

**Tips:**
- Use real generated images (not placeholders)
- Ensure good lighting in sample images
- Show festive, appealing results
- Consider adding text overlays in App Store Connect later

---

### 7. Prepare App Store Metadata
**Priority:** CRITICAL
**Status:** Draft exists in README, needs entry in App Store Connect

**Required Information:**

#### App Information
- **App Name:** HomeDesign AI — Holiday Edition
- **Subtitle:** Instantly style your home for Christmas with AI
- **Primary Category:** Lifestyle
- **Secondary Category:** Photo & Video (optional)

#### Keywords (100 characters max)
```
home design ai,christmas decor,holiday decorator,interior design,gemini ai,room decorator,christmas,ai design
```

#### Description (4000 characters max)
Use content from `README.md` "App Store Metadata" section.

**Promotional Text** (170 characters - updateable without review):
```
Transform your home for the holidays with AI! Upload a photo, pick a festive style, and see your space decorated in seconds. Try it free today!
```

#### What's New (Version 1.0)
```
🎄 Welcome to HomeDesign AI - Holiday Edition!

Transform your home for Christmas with AI-powered decoration visualization:

✨ Instant AI-Powered Styling
• Upload any room photo
• Choose from festive decoration styles
• See your space transformed in seconds

🎨 Multiple Holiday Styles
• Classic Christmas
• Winter Wonderland
• Elegant Gold
• Rustic Farmhouse
• And more!

🛍️ Shop the Look
• Get product recommendations
• Shop curated decorations on Amazon
• Bring your AI vision to life

💝 Free to Try
• 2 free generations included
• Unlock unlimited with email signup
• No subscriptions or in-app purchases

Perfect for holiday decorating inspiration!
```

#### Support & Privacy URLs
- **Privacy Policy URL:** `https://your-railway-url.up.railway.app/privacy`
- **Support URL:** `https://your-railway-url.up.railway.app/` (landing page)

#### Age Rating
**Recommended:** 4+
- No objectionable content
- Contains affiliate links (acceptable)

---

### 8. Create App Store Connect Listing
**Priority:** CRITICAL
**Status:** Not started
**Depends on:** Screenshots, metadata prepared

**Steps:**
1. Go to https://appstoreconnect.apple.com
2. Click "My Apps" → "+" → "New App"
3. Fill in:
   - **Platform:** iOS
   - **Name:** HomeDesign AI — Holiday Edition
   - **Primary Language:** English (U.S.)
   - **Bundle ID:** com.homedesign.ai (select from dropdown)
   - **SKU:** homedesignai-holiday-001 (or your choice)
   - **User Access:** Full Access
4. Click "Create"

**Then configure:**
- Add screenshots (iPhone, iPad)
- Enter description, keywords, subtitle
- Add Privacy Policy URL
- Add Support URL
- Complete age rating questionnaire
- Set price: FREE
- Add App Icon (1024x1024 already exists in Xcode)

---

### 9. Build and Upload to App Store
**Priority:** CRITICAL
**Status:** Not started
**Depends on:** All above tasks

**Steps:**
1. In Xcode, select "Any iOS Device (arm64)"
2. Product → Archive
3. Wait for archive to complete (~2-5 minutes)
4. Window → Organizer (automatically opens)
5. Select your archive → "Distribute App"
6. Select "App Store Connect"
7. Select "Upload"
8. Select signing options (automatic recommended)
9. Review app information
10. Click "Upload"
11. Wait for processing in App Store Connect (~10-30 minutes)

**Verification:**
- Check email for processing completion
- In App Store Connect, go to "TestFlight" tab
- Verify build appears (may take 10-30 minutes)

---

### 10. Submit for Review
**Priority:** CRITICAL
**Status:** Not started
**Depends on:** Build uploaded and processed

**Steps:**
1. In App Store Connect, go to your app
2. Select "Prepare for Submission"
3. Choose your uploaded build
4. Review all information one final time:
   - Screenshots ✓
   - Description ✓
   - Keywords ✓
   - Privacy Policy URL ✓
   - Support URL ✓
   - Age rating ✓
5. **Important:** Answer additional questions:
   - **Export Compliance:** No (unless your backend uses encryption beyond HTTPS)
   - **Advertising Identifier:** No (you don't use ad tracking)
   - **Content Rights:** Yes (you have rights to all content)
6. Click "Submit for Review"

**Expected Timeline:**
- Review time: 24-48 hours typically
- May be selected for additional review (can take 1-7 days)
- Check email for updates

---

## 📝 OPTIONAL BUT RECOMMENDED

### TestFlight Beta Testing
**Status:** Not started

Before public release, consider testing with beta testers:
1. After build uploads, go to TestFlight tab
2. Create "External Testing" group
3. Add testers (up to 10,000 emails)
4. Share TestFlight link
5. Get feedback before public release
6. Fix critical bugs
7. Re-submit

**Benefits:**
- Catch bugs before public launch
- Get user feedback
- Test on various devices
- Verify backend handles load

### Crash Reporting
**Status:** Not implemented

Add crash reporting to catch production issues:
- **Firebase Crashlytics** (recommended, free)
- **Sentry** (good alternative)
- **Bugsnag** (enterprise option)

**Implementation:** ~30 minutes
**Value:** Critical for debugging production crashes

### Analytics
**Status:** Placeholder code exists

Current analytics are console logs only. Consider implementing:
- **Firebase Analytics** (free, comprehensive)
- **PostHog** (open source, privacy-focused)
- **Mixpanel** (user behavior focused)

**File:** `iOS/HomeDesignAI/Services/AnalyticsService.swift`

---

## 🚨 CRITICAL REMINDERS

### Before You Submit

- [ ] **Test on physical iPhone** (not just simulator)
- [ ] **Test on physical iPad** (if possible)
- [ ] **Verify ALL links work** (Privacy, Terms, Product links)
- [ ] **Test email collection** (actually receives emails)
- [ ] **Verify image generation works** (end-to-end with Railway)
- [ ] **Check all text for typos** (App Store description, in-app text)
- [ ] **Privacy Policy is accessible** (not a 404)
- [ ] **Support email works** (you can receive support requests)

### Common Rejection Reasons to Avoid

1. **Broken links** - Test privacy/terms URLs
2. **App crashes** - Test thoroughly on real device
3. **Missing functionality** - Ensure image generation works
4. **Privacy policy missing** - URL must work and be comprehensive
5. **Misleading screenshots** - Use real app screenshots, not mockups
6. **Incomplete app information** - Fill all required fields
7. **Wrong age rating** - Answer questionnaire honestly

---

## 📊 PROGRESS TRACKER

**Overall Completion:** ~70%

- [x] Legal pages (3/3)
- [x] iOS app polish (4/4)
- [x] Backend setup (3/3)
- [ ] Deployment (0/1) ⚠️ **BLOCKING**
- [ ] URL updates (0/3) ⚠️ **BLOCKING**
- [ ] Testing (0/1) ⚠️ **BLOCKING**
- [ ] Screenshots (0/1) ⚠️ **BLOCKING**
- [ ] App Store Connect (0/3) ⚠️ **BLOCKING**

**Estimated Time Remaining:** 4-6 hours (if no blockers)

---

## 🎯 NEXT IMMEDIATE STEPS

### Step 1: Deploy to Railway (30 minutes)
Follow `RAILWAY_DEPLOYMENT.md`

### Step 2: Update URLs (10 minutes)
Update APIService.swift, AboutView.swift, privacy.html, terms.html

### Step 3: Test Everything (30 minutes)
Run through full user flow on real device

### Step 4: Screenshots (20 minutes)
Capture required screenshots in simulators

### Step 5: App Store Connect (30 minutes)
Create listing, upload build

### Step 6: Submit (5 minutes)
Click submit and wait for review

---

## 🎉 POST-SUBMISSION

After you submit, you can:
1. **Monitor review status** in App Store Connect
2. **Respond to any review feedback** if requested
3. **Prepare marketing materials** (social media posts, website, etc.)
4. **Plan v1.1 features** based on initial feedback
5. **Set up analytics** to track usage post-launch

---

**Good luck with your App Store submission!** 🚀🎄

If you have questions, refer to:
- Apple's App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- App Store Connect Help: https://developer.apple.com/app-store-connect/
- Railway Docs: https://docs.railway.app

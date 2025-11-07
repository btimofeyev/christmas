# Referral System Implementation

## Overview
Successfully replaced the email collection system with a viral referral-based reward system. Users now earn +3 generations by inviting friends, and their friends also get +3 generations when they join.

---

## What Changed

### System Architecture
- **Before**: 5 free generations → email gate → +10 more (total 15)
- **After**: 3 free generations → invite friends → +3 for each successful referral (unlimited)

### Key Benefits
- **Viral Growth**: Both referrer and referee benefit
- **Trust-Based**: Minimal restrictions as requested
- **Simple UX**: One-tap sharing with automatic tracking
- **Privacy-Friendly**: No email required

---

## Backend Changes

### New Files Created

#### 1. `Backend/routes/referral.js` (208 lines)
Handles all referral operations:

**Endpoints:**
- `POST /referral/generate-referral` - Generates unique 6-char referral code
- `POST /referral/claim-referral` - Claims referral and awards generations
- `GET /referral/referral-stats/:code` - Optional analytics endpoint

**Features:**
- Collision-free code generation (36^6 = 2B+ combinations)
- Device ID-based tracking
- Prevents self-referral
- Prevents duplicate claims
- JSON file storage in `Backend/data/referrals.json`

**Data Structure:**
```json
{
  "codes": {
    "ABC123": {
      "deviceId": "uuid",
      "createdAt": "timestamp",
      "totalClaims": 0
    }
  },
  "claims": [
    {
      "code": "ABC123",
      "claimerDeviceId": "uuid",
      "claimedAt": "timestamp"
    }
  ]
}
```

#### 2. `public/r.html` (Landing Page)
Beautiful referral landing page:
- Displays referral code prominently
- Lists benefits (AI decoration, instant results, +3 bonus)
- Auto-attempts deep link to open app if installed
- Falls back to App Store link
- Mobile-optimized design

### Modified Files

#### `Backend/index.js`
```javascript
import referralRouter from './routes/referral.js';
app.use('/referral', referralRouter);

// Referral landing page route
app.get('/r/:code', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/r.html'));
});
```

---

## iOS Changes

### New Files Created

#### 1. `iOS/HomeDesignAI/Models/ReferralModels.swift`
```swift
struct ReferralCodeResponse: Codable {
    let code: String
    let shareUrl: String
    let message: String
}

struct ReferralClaimResponse: Codable {
    let success: Bool
    let message: String
    let reward: ReferralReward
    let referrerDeviceId: String
}

struct ReferralReward: Codable {
    let claimer: Int
    let referrer: Int
}
```

#### 2. `iOS/HomeDesignAI/Views/Components/ReferralBottomSheet.swift`
Beautiful SwiftUI bottom sheet:
- Shows referral code in monospace font
- Explains reward system (+3 each)
- One-tap share button
- Displays generations remaining
- Auto-generates code on appear

### Modified Files

#### `iOS/HomeDesignAI/Utilities/Constants.swift`
```swift
enum AppConfig {
    // Generation limits and rewards
    static let initialFreeGenerations = 3
    static let referralRewardAmount = 3

    // Referral system
    static let referralBaseUrl = "https://holidayhomeai.app/r/"
    static let appStoreUrl = "https://apps.apple.com/app/holidayhome-ai/id123456789"
}
```

#### `iOS/HomeDesignAI/Services/APIService.swift`
Added two new methods:
```swift
func generateReferralCode(deviceId: String) async throws -> ReferralCodeResponse
func claimReferral(code: String, deviceId: String) async throws -> ReferralClaimResponse
```

#### `iOS/HomeDesignAI/ViewModels/HomeDesignViewModel.swift`
**Removed:**
- All email collection state and logic
- `hasSubmittedEmail`, `showEmailCapture`, `emailUnlockGenerations`
- `subscribeToMainApp()` function

**Added:**
```swift
// Referral state
@Published var showReferralPrompt = false
@Published var myReferralCode: String?
@Published var myReferralUrl: String?
@Published var isGeneratingReferralCode = false
@Published var referralRewardMessage: String = ""
@Published var showReferralReward = false

// Methods
func generateOrGetReferralCode()
func claimReferral(code: String)
func shareReferralLink() -> some View
```

**Changed:**
- Initial generations: 5 → 3
- Generation check logic simplified (no email gate)
- Reward flow: Share link → Both users get +3

#### `iOS/HomeDesignAI/Views/ResultView.swift`
**Removed:**
- Email bottom sheet (lines 409-531)
- Email-related state (`showEmailSheet`, `emailInput`)
- Auto-popup logic for email capture

**Added:**
- Prominent "Invite Friends" button after action buttons
- Golden accent color with gift icon
- Auto-shows referral sheet when user has ≤1 generations
- Sheet presentation for `ReferralBottomSheet`

#### `iOS/HomeDesignAI/Services/AnalyticsService.swift`
**Removed:**
- `emailSubscribed` event

**Added:**
```swift
case referralCodeGenerated
case referralClaimed(code: String)
```

#### `iOS/HomeDesignAI/Info.plist`
Added URL scheme for deep linking:
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>holidayhomeai</string>
        </array>
    </dict>
</array>
```

#### `iOS/HomeDesignAI/App/ContentView.swift`
Added deep link handler:
```swift
.onOpenURL { url in
    handleDeepLink(url: url)
}

private func handleDeepLink(url: URL) {
    // Handles: holidayhomeai://r/ABC123
    // Extracts code and calls viewModel.claimReferral()
}
```

---

## User Flow

### New User Experience

1. **Install App**
   - User gets 3 free generations
   - Can use app immediately

2. **After Using Free Generations**
   - "Invite Friends" button appears on ResultView
   - Auto-prompts if ≤1 generations remaining

3. **Invite Friends**
   - Tap "Invite Friends" button
   - App generates unique code (e.g., "ABC123")
   - Share sheet opens with message:
     ```
     Transform your space for the holidays with AI! 🎄✨
     Get HolidayHome AI free and we both earn +3 designs:
     https://holidayhomeai.app/r/ABC123
     ```

4. **Friend Receives Link**
   - Opens link in browser
   - Sees beautiful landing page with code
   - If app installed: Opens app automatically (deep link)
   - If not installed: Shows App Store link

5. **Friend Installs & Opens**
   - Deep link triggers: `holidayhomeai://r/ABC123`
   - App claims referral code via API
   - Both users get +3 generations
   - Success alert: "Welcome! You earned 3 free designs! 🎁"

---

## Technical Details

### Device Identification
Uses `UIDevice.current.identifierForVendor` (UUID):
- Unique per device per app
- Persists until app is uninstalled
- Resets on reinstall (acceptable for trust-based system)

### Referral Code Format
- 6 alphanumeric characters
- Excludes ambiguous chars (0,O,1,I)
- Character set: `ABCDEFGHJKLMNPQRSTUVWXYZ23456789`
- Total combinations: 34^6 = 1,544,804,416

### Storage

**Backend (JSON Files):**
- `Backend/data/referrals.json` - All referral codes and claims
- No database required (MVP approach)

**iOS (UserDefaults):**
- `my_referral_code` - User's referral code
- `my_referral_url` - Full shareable URL
- `claimed_referral_codes` - Array of codes already claimed
- `user_generations_remaining` - Current balance

### Deep Linking
**URL Schemes:**
- Custom: `holidayhomeai://r/ABC123`
- Web: `https://holidayhomeai.app/r/ABC123`

**Universal Links (Future):**
Requires:
1. Apple Developer account
2. Domain verification
3. `apple-app-site-association` file
4. Associated Domains entitlement

---

## Testing

### Backend Testing
```bash
cd Backend
npm start

# Test generate referral
curl -X POST http://localhost:3000/referral/generate-referral \
  -H "Content-Type: application/json" \
  -d '{"deviceId": "test-device-123"}'

# Test claim referral
curl -X POST http://localhost:3000/referral/claim-referral \
  -H "Content-Type: application/json" \
  -d '{"code": "ABC123", "claimerDeviceId": "test-device-456"}'

# Test landing page
open http://localhost:3000/r/ABC123
```

### iOS Testing

**Xcode Deep Link Testing:**
1. Build & run app in simulator
2. Stop the app (but keep simulator open)
3. In Terminal:
   ```bash
   xcrun simctl openurl booted "holidayhomeai://r/ABC123"
   ```
4. App should open and claim the referral

**Production Testing:**
1. TestFlight build
2. Share referral link
3. Open on different device
4. Verify both users get rewards

---

## Security Considerations

### Current Implementation (Trust-Based)
Per your request, minimal restrictions:
- No rate limiting
- Local device tracking (can be bypassed)
- No email verification
- File-based storage

### Known Vulnerabilities
1. **Reinstall Gaming**: User can delete app, reinstall, claim same code again
2. **Multiple Devices**: User can use same code on multiple devices
3. **No Server-Side Validation**: Relies on client-side checks

### Future Enhancements (If Needed)
1. **Database Migration**: PostgreSQL/MongoDB for reliability
2. **Server-Side Tracking**: Email + device ID combination
3. **Rate Limiting**: Max claims per day/week
4. **Email Verification**: Optional gate before allowing referrals
5. **Fraud Detection**: Monitor for suspicious patterns

---

## Deployment Checklist

### Before Deploying

- [ ] Update App Store URL in Constants.swift (line 102)
- [ ] Update App Store URL in public/r.html (line 88)
- [ ] Test deep linking on physical device
- [ ] Submit to App Store for URL scheme approval
- [ ] Create referrals.json file in production:
  ```bash
  mkdir -p Backend/data
  echo '{"codes":{},"claims":[]}' > Backend/data/referrals.json
  ```
- [ ] Set production environment variable for referral URL

### After Deploying

- [ ] Test referral flow end-to-end in production
- [ ] Monitor referral claims in logs
- [ ] Check for abuse patterns
- [ ] Consider adding analytics (Firebase/PostHog)

### Optional: Universal Links Setup

1. **Add domain to Apple Developer**
   - Certificates, Identifiers & Profiles
   - Add Associated Domains capability
   - Add `applinks:holidayhomeai.app`

2. **Create apple-app-site-association**
   ```json
   {
     "applinks": {
       "apps": [],
       "details": [{
         "appID": "TEAM_ID.com.your.bundleid",
         "paths": ["/r/*"]
       }]
     }
   }
   ```

3. **Host at root**
   - `https://holidayhomeai.app/.well-known/apple-app-site-association`
   - Content-Type: `application/json`
   - No file extension

4. **Update Info.plist**
   ```xml
   <key>com.apple.developer.associated-domains</key>
   <array>
       <string>applinks:holidayhomeai.app</string>
   </array>
   ```

---

## File Summary

### Created (5 files)
1. `Backend/routes/referral.js` - Referral API endpoints
2. `Backend/data/referrals.json` - Referral data storage (auto-created)
3. `iOS/HomeDesignAI/Models/ReferralModels.swift` - API response models
4. `iOS/HomeDesignAI/Views/Components/ReferralBottomSheet.swift` - Invite UI
5. `public/r.html` - Landing page for referral links

### Modified (8 files)
1. `Backend/index.js` - Added referral routes
2. `iOS/HomeDesignAI/Utilities/Constants.swift` - Updated limits & config
3. `iOS/HomeDesignAI/Services/APIService.swift` - Added referral endpoints
4. `iOS/HomeDesignAI/ViewModels/HomeDesignViewModel.swift` - Removed email, added referral
5. `iOS/HomeDesignAI/Views/ResultView.swift` - Replaced email sheet with invite button
6. `iOS/HomeDesignAI/Services/AnalyticsService.swift` - Updated events
7. `iOS/HomeDesignAI/Info.plist` - Added URL scheme
8. `iOS/HomeDesignAI/App/ContentView.swift` - Added deep link handler

### Deleted Logic (not files)
- Email collection bottom sheet
- Email submission logic
- Email-based generation unlocking

---

## Metrics to Track

### User Acquisition
- Referral link clicks
- App installs from referrals
- Conversion rate (clicks → installs)

### Engagement
- Referrals created per user
- Average successful referrals per user
- Retention of referred users vs. organic

### Viral Coefficient
- K-factor = (invited users who convert) × (invites per user)
- Target: K > 1 for viral growth

### Abuse Detection
- Multiple claims from same device
- Rapid successive claims
- Codes with unusually high claim counts

---

## Next Steps

### Immediate (Before Launch)
1. Test on physical device
2. Update App Store URLs
3. Deploy backend with referrals.json
4. TestFlight beta testing

### Short-Term (First Month)
1. Monitor referral usage
2. A/B test reward amounts (3 vs 5 vs unlimited)
3. Add simple analytics dashboard
4. Collect user feedback

### Long-Term (If Scaling)
1. Migrate to database
2. Add server-side fraud detection
3. Implement Universal Links
4. Add referral leaderboard
5. Consider premium tier

---

## Support

### Troubleshooting

**"Deep link not working"**
- Check URL scheme in Info.plist
- Verify app is installed
- Test with `xcrun simctl openurl`

**"Referral code not generating"**
- Check backend connectivity
- Verify device ID is valid
- Check API logs for errors

**"Already claimed" error**
- User previously claimed this code
- Check `claimed_referral_codes` in UserDefaults
- Cannot claim own code

**"Backend referrals.json not found"**
- File is auto-created on first request
- Ensure `Backend/data/` directory exists
- Check file permissions

---

## Conclusion

Successfully implemented a viral referral system that:
- ✅ Removed email collection dependency
- ✅ Simplified to 3 free generations initially
- ✅ +3 generations per successful referral (both users)
- ✅ Trust-based with minimal restrictions
- ✅ Beautiful UX with one-tap sharing
- ✅ Deep linking for seamless claiming
- ✅ Landing page for web → app flow
- ✅ All backend and iOS changes complete
- ✅ Syntax validated, ready to deploy

The system is designed for viral growth while maintaining a simple, privacy-friendly user experience.

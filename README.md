# HomeDesign AI - Christmas Edition

> AI-powered Christmas decoration app for iOS. Upload a photo and get instant AI-generated holiday decoration ideas with product recommendations.

**Status**: 🚀 Deployed on Railway + TestFlight

---

## Features

- 📸 **Camera & Photo Upload**: Native iOS camera integration
- 🎨 **AI-Powered Decoration**: Google Gemini generates realistic Christmas décor
- 🏠 **Interior & Exterior Support**: Works for both indoor and outdoor spaces
- 🎭 **4 Style Presets**: Classic Christmas, Nordic Minimalist, Modern Silver, Cozy Family
- ✏️ **Custom Prompts**: Describe your own unique decoration style
- 🔄 **Before/After Slider**: Interactive image comparison
- 🛍️ **Shop the Look**: Curated Amazon affiliate product recommendations
- 🔒 **100% Privacy**: No login required, images never stored, ephemeral processing
- 💾 **Save & Share**: Export decorated images locally

---

## Quick Start

### Backend (Railway)

The backend is deployed on Railway. To run locally:

```bash
cd Backend
npm install
npm start
```

Set these environment variables in Railway:
```
API_KEY=your_google_gemini_api_key
NODE_ENV=production
PORT=3000
ALLOWED_ORIGINS=your-railway-url,capacitor://localhost,ionic://localhost
AMAZON_AFFILIATE_TAG=homedesignai-20
```

⚠️ **IMPORTANT**: Never commit `.env` files. See `SECURITY_URGENT.md` for setup details.

### iOS (TestFlight)

The iOS app is in TestFlight. To build locally:

1. Open `iOS/HomeDesignAI.xcodeproj` in Xcode
2. Update API endpoint in `Services/APIService.swift` if needed
3. Build and run (Cmd+R)

---

## Project Structure

```
HomeDesignAI/
├── Backend/              # Node.js API (Railway)
│   ├── index.js         # Express server
│   ├── gemini/          # Google Gemini AI integration
│   ├── routes/          # API endpoints (/generate, /subscribe)
│   ├── utils/           # Validation utilities
│   └── data/            # Product catalog
├── iOS/                 # Native iOS app (TestFlight)
│   └── HomeDesignAI/    # Swift/SwiftUI source
└── public/              # Static web assets
```

---

## API Endpoints

### POST /generate
Generate decorated image from uploaded photo

**Request:**
```json
{
  "scene": "interior",
  "style": "classic_christmas",
  "image_base64": "data:image/jpeg;base64,..."
}
```

**Response:**
```json
{
  "decorated_image_base64": "data:image/jpeg;base64,...",
  "products": [...],
  "meta": {"style": "...", "timestamp": "..."}
}
```

### POST /subscribe
Email subscription for launch notifications

### GET /health
Health check endpoint

---

## Security & Privacy

- **No data storage**: All images processed in-memory only
- **Environment variables**: API keys never committed to git
- **CORS protection**: Restricted to authorized origins only
- **Input validation**: All API requests validated before processing

---

## Development

### Backend
```bash
cd Backend
npm install
npm start
```

### iOS
Open `iOS/HomeDesignAI.xcodeproj` in Xcode and build (Cmd+R)

---

## Deployment

### Backend (Railway)
- Connected to git repository
- Auto-deploys on push to main
- Environment variables set in Railway dashboard

### iOS (TestFlight)
- Archive in Xcode (Product → Archive)
- Upload to App Store Connect
- Submit for TestFlight review

---

## Documentation

- `Backend/README.md` - Full API documentation
- `SECURITY_URGENT.md` - Security setup and deployment instructions

---

## License

MIT

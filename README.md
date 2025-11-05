# 🎄 HomeDesign AI — Holiday Edition (MVP)

> "See your home beautifully decorated for Christmas — instantly with AI."

An Apple-inspired iOS app that lets users upload a photo of their space and instantly visualize it decorated for Christmas, powered by Google Gemini. The app delivers a realistic, high-quality render of the decorated space and displays curated décor products with affiliate purchase links.

**Tagline**: *Your home. Your style. Instantly designed.*

---

## ✨ Features

- 📸 **Instant Upload**: Use camera or photo library
- 🎨 **AI-Powered Decoration**: Google Gemini generates realistic Christmas décor
- 🏠 **Interior & Exterior**: Support for both indoor and outdoor spaces
- 🎭 **4 Style Presets**:
  - Classic Christmas (red & gold)
  - Nordic Minimalist (white & natural)
  - Modern Silver (sleek & metallic)
  - Cozy Family (warm & rustic)
- ✏️ **Custom Prompts**: Describe your own unique style
- 🔄 **Before/After Slider**: Interactive comparison
- 🛍️ **Shop the Look**: Curated affiliate product recommendations
- 🔒 **100% Privacy**: No login, no data storage, ephemeral processing
- 💾 **Save & Share**: Export decorated images locally

---

## 🚀 Quick Start

### Prerequisites

- **iOS Development**:
  - macOS with Xcode 15+
  - iOS 17+ device or simulator

- **Backend**:
  - Node.js 18+
  - Google Gemini API key ([Get one here](https://makersuite.google.com/app/apikey))

### 1. Backend Setup

```bash
# Navigate to backend directory
cd HomeDesignAI/Backend

# Install dependencies
npm install

# Configure environment
cp .env.example .env

# Edit .env and add your Gemini API key
# GEMINI_API_KEY=your_key_here

# Start the server
npm start
```

Backend will run on `http://localhost:3000`

### 2. iOS App Setup

1. **Open Xcode**
2. **Create new App project**:
   - Product Name: `HomeDesignAI`
   - Interface: SwiftUI
   - Language: Swift
   - Minimum Deployment: iOS 17.0

3. **Add source files**:
   - Delete default `ContentView.swift` and `HomeDesignAIApp.swift`
   - Drag the `iOS/HomeDesignAI` folder into Xcode project
   - Select "Create groups" and "Copy items if needed"

4. **Configure Info.plist**:
   - Use the provided `Info.plist` or add camera/photo permissions manually

5. **Build and Run** (Cmd+R)

### 3. Test the App

1. Ensure backend is running on port 3000
2. Launch app in simulator
3. Upload a room photo
4. Select style preset
5. Wait for AI generation (currently returns original - see note below)
6. View result with before/after slider
7. Browse "Shop the Look" products

---

## 📁 Project Structure

```
HomeDesignAI/
├── Backend/              # Node.js serverless API
│   ├── index.js         # Express server
│   ├── gemini/          # Gemini API integration
│   ├── routes/          # API endpoints
│   ├── data/            # Affiliate product data
│   └── README.md        # Backend documentation
│
└── iOS/                  # SwiftUI iOS app
    ├── HomeDesignAI/
    │   ├── App/         # App entry point
    │   ├── Models/      # Data models
    │   ├── Views/       # SwiftUI views
    │   ├── ViewModels/  # MVVM business logic
    │   ├── Services/    # API, image processing, analytics
    │   └── Utilities/   # Constants, extensions
    └── README.md        # iOS documentation
```

---

## 🏗️ Architecture

### Backend (Node.js)
- **Stateless**: No data persistence
- **Privacy-First**: Images processed in-memory only
- **RESTful API**: Single `/generate` endpoint
- **Gemini Integration**: AI-powered decoration

### iOS (SwiftUI)
- **MVVM Pattern**: Clean separation of concerns
- **Reactive**: SwiftUI + Combine
- **Apple Design**: SF Symbols, native components
- **Privacy**: No tracking, local processing

---

## ⚠️ Important Note: Image Generation

The current backend implementation uses **Google Gemini Pro Vision**, which can analyze images but **does NOT generate new images**.

To enable actual image generation, integrate one of these services in `Backend/gemini/geminiService.js`:

1. **Google Imagen** (Recommended - same ecosystem)
2. **OpenAI DALL-E 3**
3. **Stability AI (Stable Diffusion)**
4. **Midjourney API**

The framework is ready - you just need to add the image generation API call.

---

## 🎨 Design System

### Colors
- Background: `#FAFAFA` (off-white)
- Text: `#222222` (charcoal)
- Gold Accent: `#D4AF37`
- Card: White

### Typography
- SF Pro Display (titles)
- SF Pro Text (body)

### Spacing
- Clean, spacious margins
- Consistent 8pt grid system

---

## 📊 API Documentation

### POST `/generate`

Generate Christmas-decorated image.

**Request**:
```json
{
  "scene": "interior",
  "style": "classic_christmas",
  "prompt": "Optional custom description",
  "image_base64": "data:image/jpeg;base64,..."
}
```

**Response**:
```json
{
  "decorated_image_base64": "data:image/jpeg;base64,...",
  "products": [
    {
      "name": "Pre-Lit Christmas Tree",
      "price": "$349",
      "image": "https://...",
      "link": "https://affiliate-link"
    }
  ]
}
```

Full API docs: See `Backend/README.md`

---

## 🛠️ Development

### Backend Development
```bash
cd Backend
npm run dev  # Auto-reload on changes
```

### iOS Development
1. Open Xcode project
2. Make changes to Swift files
3. Cmd+R to build and test

---

## 🚀 Deployment

### Backend

**Vercel** (Recommended):
```bash
cd Backend
vercel
```

**Google Cloud Run**:
```bash
gcloud builds submit --tag gcr.io/[PROJECT-ID]/homedesign-backend
gcloud run deploy homedesign-backend --image gcr.io/[PROJECT-ID]/homedesign-backend
```

### iOS

1. Archive in Xcode (Product → Archive)
2. Distribute to App Store Connect
3. Submit for review

---

## 📈 MVP Metrics

| Metric | Target |
|--------|--------|
| Render success rate | ≥ 95% |
| Median generation time | ≤ 45 sec |
| Activation rate | ≥ 60% |
| Affiliate CTR | 10-20% |
| Render cost | ≤ $0.25 per request |

---

## 🔮 Future Roadmap

- [ ] Add user accounts (Supabase)
- [ ] Seasonal packs (Spring, Summer, Fall)
- [ ] Auto-tag product detection
- [ ] Brand sponsorships
- [ ] Analytics dashboard
- [ ] Multi-language support
- [ ] iPad optimization

---

## 🔒 Privacy

- **No User Accounts**: Zero-friction experience
- **No Data Storage**: Images never persisted
- **Ephemeral Processing**: In-memory only
- **No Tracking**: Analytics placeholder only
- **Local Image Processing**: Compression on-device

---

## 📱 App Store Listing

**Title**: HomeDesign AI — Holiday Edition
**Subtitle**: Instantly style your home for Christmas with AI
**Description**: Upload a photo of your home and let HomeDesign AI decorate it for Christmas — instantly and beautifully. Choose from preset styles or describe your own.

**Keywords**: home design ai, christmas decor, holiday decorator, interior design, gemini ai

**Screenshots**:
1. Upload your space
2. Select your scene & style
3. Watch your home transform
4. Shop the Look

---

## 🤝 Contributing

This is an MVP built for the 2025 holiday season. Feel free to:
- Report issues
- Suggest features
- Submit PRs

---

## 📄 License

MIT

---

## 🎯 Definition of Done

- [x] User can upload a photo (no login)
- [x] Select interior/exterior and style or enter prompt
- [x] Backend generates API response (Gemini integration ready)
- [x] "Shop the Look" renders affiliate décor products
- [x] No user data stored anywhere
- [x] App works smoothly on iPhone 12-15 (iOS 17+)
- [ ] **TODO**: Integrate actual image generation API

---

## 📚 Documentation

- [Backend README](Backend/README.md) - API documentation, deployment
- [iOS README](iOS/README.md) - App setup, architecture, testing

---

**Built with ❤️ for the 2025 holiday season**

🎄 Happy decorating!

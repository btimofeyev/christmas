# HomeDesign AI - iOS App

SwiftUI iOS app for HomeDesign AI Christmas Edition. Upload a photo of your home and instantly see it decorated for Christmas with AI.

## Features

- **Clean Apple-Inspired Design**: Minimal, beautiful UI following iOS design guidelines
- **Camera & Photo Library Support**: Capture or select photos
- **Scene Selection**: Interior or Exterior
- **4 Style Presets**: Classic Christmas, Nordic Minimalist, Modern Silver, Cozy Family
- **Custom Prompts**: Describe your own unique style
- **Before/After Slider**: Interactive comparison
- **Shop the Look**: Curated affiliate product recommendations
- **Privacy-Focused**: No login, no data storage
- **Save & Share**: Export decorated images

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Setup Instructions

### 1. Create Xcode Project

Since Xcode projects can't be created programmatically, follow these steps:

1. **Open Xcode**
2. **Create a new project**:
   - Choose "App" template
   - Product Name: `HomeDesignAI`
   - Interface: SwiftUI
   - Language: Swift
   - Minimum Deployment: iOS 17.0

3. **Delete the default files**:
   - Delete `ContentView.swift` (we have our own)
   - Delete `HomeDesignAIApp.swift` (we have our own)

4. **Add all source files to the project**:
   - Drag the `HomeDesignAI` folder into Xcode
   - Select "Create groups"
   - Make sure "Copy items if needed" is checked

### 2. Configure Info.plist

The `Info.plist` file is already created with necessary permissions:
- Camera access
- Photo library access
- Photo library add access

In Xcode, go to your app target → Info tab and verify these permissions are present.

### 3. Configure Backend URL

In `Services/APIService.swift`, update the backend URL:

```swift
private var baseURL: String {
    #if DEBUG
    return "http://localhost:3000"  // Local development
    #else
    return "https://your-backend-url.com"  // Production URL
    #endif
}
```

### 4. Build and Run

1. Select a simulator or device
2. Press Cmd+R to build and run
3. Make sure the backend is running on `http://localhost:3000`

## Project Structure

```
HomeDesignAI/
├── App/
│   ├── HomeDesignAIApp.swift       # App entry point
│   └── ContentView.swift           # Main navigation view
├── Models/
│   ├── DecorStyle.swift            # Style presets enum
│   ├── SceneType.swift             # Interior/Exterior enum
│   ├── GenerateRequest.swift       # API request model
│   ├── GenerateResponse.swift      # API response model
│   └── AffiliateProduct.swift      # Product model
├── Views/
│   ├── WelcomeView.swift           # Welcome screen
│   ├── UploadPhotoView.swift       # Photo upload
│   ├── SceneSelectionView.swift    # Interior/Exterior selection
│   ├── StyleSelectionView.swift    # Style preset selection
│   ├── GeneratingView.swift        # Loading screen
│   ├── ResultView.swift            # Result with before/after
│   └── Components/
│       ├── BeforeAfterSlider.swift # Interactive slider
│       ├── ProductCard.swift       # Product card
│       └── StylePresetCard.swift   # Style preset card
├── ViewModels/
│   └── HomeDesignViewModel.swift   # Main MVVM ViewModel
├── Services/
│   ├── APIService.swift            # Backend communication
│   ├── ImageProcessor.swift        # Image compression/conversion
│   └── AnalyticsService.swift      # Analytics (placeholder)
├── Utilities/
│   ├── Constants.swift             # Design system constants
│   └── Extensions.swift            # Swift extensions
└── Info.plist                      # App permissions
```

## Architecture

### MVVM Pattern

The app uses the Model-View-ViewModel (MVVM) architecture:

- **Models**: Data structures (DecorStyle, SceneType, etc.)
- **Views**: SwiftUI views (WelcomeView, ResultView, etc.)
- **ViewModel**: `HomeDesignViewModel` manages all app state and business logic

### Navigation Flow

```
Welcome → Upload Photo → Scene Selection → Style Selection → Generating → Result
```

All navigation is managed by `HomeDesignViewModel.currentStep` with smooth animations.

## Design System

### Colors
- Background: `#FAFAFA` (off-white)
- Text: `#222222` (charcoal)
- Accent: `#D4AF37` (gold)
- Card: White

### Typography
- SF Pro Display (titles)
- SF Pro Text (body)

### Spacing
- XS: 4pt
- SM: 8pt
- MD: 16pt
- LG: 24pt
- XL: 32pt
- XXL: 48pt

## Testing

### Simulator Testing

1. **Camera Simulation**: Simulator doesn't support camera, but you can:
   - Select from photo library
   - Drag images into simulator

2. **Test Images**: Add sample room photos to the simulator's photo library

### Backend Connection

Make sure the backend is running:
```bash
cd ../Backend
npm start
```

The app will connect to `http://localhost:3000` in debug mode.

## Analytics Integration (Future)

The app has a placeholder `AnalyticsService` ready for integration with:
- Firebase Analytics
- PostHog
- Mixpanel

To integrate, implement the methods in `Services/AnalyticsService.swift`.

## Privacy

- **No Login**: No user accounts required
- **No Storage**: Images processed in-memory only
- **No Tracking**: Analytics placeholder only
- **Local Processing**: Image compression happens on-device

## App Store Submission

When ready to submit:

1. **Update Info.plist**: Add privacy manifest
2. **Add App Icons**: Create icon set in Assets.xcassets
3. **Screenshots**: Capture required sizes
4. **App Description**: Use provided PRD copy
5. **Keywords**: `home design ai, christmas decor, holiday decorator, interior design`

## Troubleshooting

### Build Errors

**Missing files**:
- Make sure all Swift files are added to the target
- Check "Target Membership" in File Inspector

**Import errors**:
- Clean build folder (Cmd+Shift+K)
- Rebuild (Cmd+B)

### Runtime Issues

**API not connecting**:
- Check backend is running on port 3000
- Verify URL in `APIService.swift`
- Check simulator network permissions

**Images not uploading**:
- Check photo library permissions in Settings app
- Verify Info.plist has usage descriptions

## License

MIT

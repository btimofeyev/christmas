# HomeDesign AI - Backend

Stateless Node.js backend for HomeDesign AI Christmas Edition. Powered by Google Gemini for AI-generated Christmas decorations.

## Features

- **Stateless Architecture**: No data persistence - all processing in-memory
- **Privacy-Focused**: Images never stored, automatically discarded post-response
- **Google Gemini Integration**: AI-powered image decoration
- **4 Preset Styles**: Classic Christmas, Nordic Minimalist, Modern Silver, Cozy Family
- **Custom Prompts**: Users can describe their own decoration style
- **Affiliate Products**: Returns curated product recommendations per style

## Prerequisites

- Node.js 18+
- Google Gemini API key ([Get one here](https://makersuite.google.com/app/apikey))

## Installation

1. **Install dependencies**:
   ```bash
   npm install
   ```

2. **Configure environment variables**:
   ```bash
   cp .env.example .env
   ```

3. **Edit `.env` and add your Gemini API key**:
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   PORT=3000
   ```

## Running Locally

```bash
npm start
```

Server will start on `http://localhost:3000`

## API Endpoints

### POST `/generate`

Generates a Christmas-decorated version of an uploaded image.

**Request Body**:
```json
{
  "scene": "interior",
  "style": "classic_christmas",
  "prompt": "Optional custom prompt (required if style is 'custom')",
  "image_base64": "data:image/jpeg;base64,..."
}
```

**Parameters**:
- `scene` (required): `"interior"` or `"exterior"`
- `style` (required): `"classic_christmas"`, `"nordic_minimalist"`, `"modern_silver"`, `"cozy_family"`, or `"custom"`
- `prompt` (optional): Custom decoration description (required when style is `"custom"`)
- `image_base64` (required): Base64-encoded image data URL

**Response**:
```json
{
  "decorated_image_base64": "data:image/jpeg;base64,...",
  "products": [
    {
      "name": "Pre-Lit Premium Christmas Tree",
      "price": "$349",
      "image": "https://...",
      "link": "https://affiliate-link"
    }
  ],
  "meta": {
    "style": "classic_christmas",
    "scene": "interior",
    "timestamp": "2024-12-01T12:00:00.000Z"
  }
}
```

### GET `/health`

Health check endpoint.

**Response**:
```json
{
  "status": "ok",
  "service": "HomeDesign AI Backend",
  "timestamp": "2024-12-01T12:00:00.000Z"
}
```

## Style Presets

### Classic Christmas
Rich red and gold accents with traditional garland, tree, and stockings.

### Nordic Minimalist
White, pine, and natural woods — clean and modern.

### Modern Silver
White and metallic tones, elegant and sleek.

### Cozy Family
Warm lighting, rustic decorations, soft textures.

## Privacy & Data Handling

- **No Storage**: Images exist only in memory during processing
- **Automatic Cleanup**: Data discarded immediately after response
- **No Logs**: Photo content never logged
- **Ephemeral**: 100% transient data compliance

## Deployment

### Vercel

1. Install Vercel CLI:
   ```bash
   npm i -g vercel
   ```

2. Deploy:
   ```bash
   vercel
   ```

3. Set environment variables in Vercel dashboard:
   - `GEMINI_API_KEY`

### Google Cloud Run

1. Build container:
   ```bash
   gcloud builds submit --tag gcr.io/[PROJECT-ID]/homedesign-backend
   ```

2. Deploy:
   ```bash
   gcloud run deploy homedesign-backend \
     --image gcr.io/[PROJECT-ID]/homedesign-backend \
     --platform managed \
     --set-env-vars GEMINI_API_KEY=[YOUR_KEY]
   ```

## Important Notes

### Image Generation Limitation

⚠️ **IMPORTANT**: The current implementation uses Google Gemini Pro Vision, which can **analyze** images but does NOT generate new images.

To enable actual image generation, you need to integrate with one of these services:

1. **Google Imagen** (Recommended - same ecosystem as Gemini)
2. **OpenAI DALL-E 3**
3. **Stability AI (Stable Diffusion)**
4. **Midjourney API**

The framework is built and ready - you just need to add the image generation API integration in `gemini/geminiService.js`.

## Project Structure

```
Backend/
├── index.js              # Express server
├── gemini/
│   └── geminiService.js  # Gemini API integration
├── routes/
│   └── generate.js       # /generate endpoint
├── utils/
│   └── validation.js     # Request validation
├── data/
│   └── products.json     # Affiliate product data
└── package.json
```

## Development

Run with auto-reload:
```bash
npm run dev
```

## Cost Estimation

- Gemini API: ~$0.001-0.01 per request
- Hosting (Vercel/Cloud Run): Free tier available
- Target: ≤ $0.25 per request

## License

MIT

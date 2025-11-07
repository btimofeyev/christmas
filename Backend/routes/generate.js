import express from 'express';
import { generateDecoratedImage, findSimilarProducts } from '../gemini/geminiService.js';
import { validateGenerateRequest, extractBase64, getMimeType } from '../utils/validation.js';
import { readFile } from 'fs/promises';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const router = express.Router();

// Test endpoint to verify route is working
router.get('/', (req, res) => {
  res.json({ message: 'Generate route is working! Use POST to generate images.' });
});

// Get current directory for loading product data
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * POST /generate
 * Main endpoint for generating decorated images
 *
 * Request body:
 * {
 *   "scene": "interior" | "exterior",
 *   "style": "classic_christmas" | "nordic_minimalist" | "modern_silver" | "cozy_family" | "rustic_farmhouse" | "elegant_gold" | "colorful_whimsical" | "custom",
 *   "prompt": "custom decoration description" (required if style is "custom"),
 *   "lighting": "day" | "night",
 *   "intensity": "minimal" | "light" | "medium" | "heavy" | "maximal" (optional, defaults to "medium"),
 *   "image_base64": "data:image/jpeg;base64,..."
 * }
 *
 * Response:
 * {
 *   "decorated_image_base64": "data:image/png;base64,...",
 *   "products": [
 *     {
 *       "name": "Product Name",
 *       "price": "$XX",
 *       "image": "https://...",
 *       "link": "https://amazon.com/search?..."
 *     }
 *   ]
 * }
 */
router.post('/', async (req, res) => {
  console.log('🎨 POST /generate hit! Body keys:', Object.keys(req.body));
  try {
    // Validate request
    const validation = validateGenerateRequest(req.body);
    if (!validation.valid) {
      return res.status(400).json({
        error: 'Invalid request',
        details: validation.errors
      });
    }

    const { scene, style, prompt, lighting = 'day', intensity = 'medium', image_base64 } = req.body;

    // Extract base64 data and MIME type
    const base64Data = extractBase64(image_base64);
    const mimeType = getMimeType(image_base64);

    if (!base64Data) {
      return res.status(400).json({
        error: 'Invalid image format',
        details: ['Could not extract base64 data from image']
      });
    }

    console.log(`\n🎨 Generating ${style} decoration for ${scene} scene (${lighting} lighting, ${intensity} intensity)...`);

    // Step 1: Generate decorated image using Gemini
    const generatedImage = await generateDecoratedImage(
      base64Data,
      mimeType,
      style,
      scene,
      prompt,
      lighting,
      intensity
    );

    // Step 2: Analyze generated image for product recommendations
    let products = [];
    try {
      const aiProducts = await findSimilarProducts(
        generatedImage.imageBase64,
        generatedImage.mimeType
      );

      // Convert AI products to iOS app format with affiliate links
      const affiliateTag = process.env.AMAZON_AFFILIATE_TAG || '';
      products = aiProducts.map((product) => ({
        name: product.productName,
        price: 'From $19.99', // Realistic starting price
        image: 'https://images.unsplash.com/photo-1512389142860-9c449e58a543?w=400', // Placeholder
        link: `https://www.amazon.com/s?k=${encodeURIComponent(product.searchTerm)}${affiliateTag ? `&tag=${affiliateTag}` : ''}`
      }));

      // If AI didn't find enough products, supplement with static fallback
      if (products.length < 4) {
        console.log('⚠️  AI found fewer than 4 products, adding fallback products...');
        const fallbackProducts = await loadFallbackProducts(style);
        const needed = 4 - products.length;
        products = [...products, ...fallbackProducts.slice(0, needed)];
      }
    } catch (error) {
      console.error('⚠️  Product detection failed, using fallback products:', error.message);
      // If product detection fails, use static fallback
      products = await loadFallbackProducts(style);
    }

    // Build response
    const response = {
      decorated_image_base64: `data:${generatedImage.mimeType};base64,${generatedImage.imageBase64}`,
      products: products,
      meta: {
        style: style,
        scene: scene,
        intensity: intensity,
        lighting: lighting,
        timestamp: new Date().toISOString(),
        aiGenerated: true
      }
    };

    console.log('✅ Generation complete\n');

    // Return response (data is automatically cleared from memory after this)
    res.json(response);

  } catch (error) {
    console.error('❌ Generate endpoint error:', error);
    res.status(500).json({
      error: 'Failed to generate decorated image',
      message: error.message
    });
  }
});

/**
 * Load fallback products from static JSON file
 */
async function loadFallbackProducts(style) {
  try {
    const productDataPath = join(__dirname, '../data/products.json');
    const productData = await readFile(productDataPath, 'utf-8');
    const allProducts = JSON.parse(productData);

    // Get products for this style, or default if custom
    const products = allProducts[style] || allProducts['classic_christmas'] || [];

    // Add affiliate tag to all product links
    const affiliateTag = process.env.AMAZON_AFFILIATE_TAG || '';
    if (affiliateTag) {
      return products.map(product => ({
        ...product,
        link: product.link.includes('?')
          ? `${product.link}&tag=${affiliateTag}`
          : `${product.link}?tag=${affiliateTag}`
      }));
    }

    return products;
  } catch (error) {
    console.error('Error loading fallback products:', error);
    // Return empty array if products file doesn't exist
    return [];
  }
}

export default router;

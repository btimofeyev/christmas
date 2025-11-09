import express from 'express';
import { generateDecoratedImage, findSimilarProducts } from '../gemini/geminiService.js';
import { validateGenerateRequest, extractBase64, getMimeType } from '../utils/validation.js';
import { readFile } from 'fs/promises';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { getOrCreateUser, updateUserGenerations } from '../db/database.js';

const router = express.Router();


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
 *   "style": "classic_christmas" | "nordic_minimalist" | "modern_silver" | "cozy_family" | "rustic_farmhouse" | "elegant_gold" | "custom",
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
  console.log('📥 /generate request received:', {
    scene: req.body.scene,
    style: req.body.style,
    lighting: req.body.lighting,
    intensity: req.body.intensity,
    hasPrompt: !!req.body.prompt,
    hasImage: !!req.body.image_base64,
    imageLength: req.body.image_base64?.length || 0
  });

  try {
    // Validate request
    const validation = validateGenerateRequest(req.body);
    if (!validation.valid) {
      console.error('❌ Validation failed:', validation.errors);
      return res.status(400).json({
        error: 'Invalid request',
        details: validation.errors
      });
    }

    const { scene, style, prompt, lighting = 'day', intensity = 'medium', image_base64, device_id } = req.body;

    // Validate device_id is provided
    if (!device_id) {
      console.error('❌ Missing device_id');
      return res.status(400).json({
        error: 'Missing device_id',
        details: ['device_id is required for generation tracking']
      });
    }

    // Check user's generation limit
    console.log('📊 Checking generation limit for device:', device_id);
    const user = await getOrCreateUser(device_id);

    if (user.generations_remaining <= 0) {
      console.warn('⚠️  User has no generations remaining');
      return res.status(403).json({
        error: 'No generations remaining',
        message: 'You have used all your free designs. Share your referral code to earn more!',
        generationsRemaining: 0,
        totalGenerated: user.total_generated
      });
    }

    console.log(`✅ User has ${user.generations_remaining} generations remaining`);

    // Extract base64 data and MIME type
    const base64Data = extractBase64(image_base64);
    const mimeType = getMimeType(image_base64);

    if (!base64Data) {
      console.error('❌ Could not extract base64 data from image');
      return res.status(400).json({
        error: 'Invalid image format',
        details: ['Could not extract base64 data from image']
      });
    }

    console.log('✅ Validation passed, calling generateDecoratedImage...');

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

    console.log('✅ Image generated successfully, size:', generatedImage.imageBase64?.length || 0);

    // Update user's generation count in database
    const newGenerationsRemaining = user.generations_remaining - 1;
    const newTotalGenerated = user.total_generated + 1;
    await updateUserGenerations(device_id, newGenerationsRemaining, newTotalGenerated);
    console.log(`📊 Updated user stats: ${newGenerationsRemaining} remaining, ${newTotalGenerated} total`);

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
        const fallbackProducts = await loadFallbackProducts(style);
        const needed = 4 - products.length;
        products = [...products, ...fallbackProducts.slice(0, needed)];
      }
    } catch (error) {
      if (process.env.NODE_ENV !== 'production') {
        console.error('⚠️  Product detection failed, using fallback products:', error.message);
      }
      // If product detection fails, use static fallback
      products = await loadFallbackProducts(style);
    }

    // Build response
    const response = {
      decorated_image_base64: `data:${generatedImage.mimeType};base64,${generatedImage.imageBase64}`,
      products: products,
      generationsRemaining: newGenerationsRemaining,
      totalGenerated: newTotalGenerated,
      meta: {
        style: style,
        scene: scene,
        intensity: intensity,
        lighting: lighting,
        timestamp: new Date().toISOString(),
        aiGenerated: true
      }
    };

    // Return response (data is automatically cleared from memory after this)
    res.json(response);

  } catch (error) {
    console.error('❌ Generate endpoint error!');
    console.error('Error name:', error.name);
    console.error('Error message:', error.message);
    console.error('Error code:', error.code);
    console.error('Error status:', error.status);
    console.error('Error stack:', error.stack);
    console.error('Full error:', JSON.stringify(error, Object.getOwnPropertyNames(error), 2));

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
    if (process.env.NODE_ENV !== 'production') {
      console.error('Error loading fallback products:', error);
    }
    // Return empty array if products file doesn't exist
    return [];
  }
}

export default router;

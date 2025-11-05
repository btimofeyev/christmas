import { GoogleGenAI, Modality, Type } from '@google/genai';

// Initialize AI client (lazy - will be created when first used)
let ai = null;

function getAIClient() {
  if (!ai) {
    if (!process.env.API_KEY) {
      throw new Error('API_KEY environment variable is not set');
    }
    ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
  }
  return ai;
}

/**
 * Gets intensity-specific decoration guidance
 * @param {string} intensity - The decoration intensity level
 * @returns {object} Intensity guidance for prompts
 */
function getIntensityGuidance(intensity = 'medium') {
  const intensityMap = {
    minimal: {
      coverage: 'very sparse and minimal',
      quantity: 'just a few key pieces',
      approach: 'Use restraint and focus on 1-2 focal points only',
      descriptor: 'extremely understated',
    },
    light: {
      coverage: 'light and tasteful',
      quantity: 'a modest selection',
      approach: 'Add decorations sparingly in key areas',
      descriptor: 'subtle and refined',
    },
    medium: {
      coverage: 'balanced',
      quantity: 'a good variety',
      approach: 'Decorate main areas with balanced coverage',
      descriptor: 'pleasantly decorated',
    },
    heavy: {
      coverage: 'generous and abundant',
      quantity: 'numerous decorative elements',
      approach: 'Add extensive decorations throughout the space',
      descriptor: 'richly decorated',
    },
    maximal: {
      coverage: 'lavish and fully decorated',
      quantity: 'an abundance of decorations',
      approach: 'Fill the space with maximum festive decorations in every visible area',
      descriptor: 'spectacularly decorated with no bare spaces',
    },
  };

  return intensityMap[intensity] || intensityMap.medium;
}

/**
 * Gets a base style description based on scene type and intensity
 * @param {string} style - The decoration style
 * @param {string} scene - 'interior' or 'exterior'
 * @param {string} intensity - Decoration intensity level
 * @returns {string} The base decoration description
 */
function getBaseStyleDescription(style, scene, intensity = 'medium') {
  const isExterior = scene === 'exterior';
  const intensityGuide = getIntensityGuidance(intensity);

  // More flexible preservation rules that allow layering
  const preserve = isExterior
    ? 'Maintain the original house architecture and structure.'
    : 'Maintain the original room structure and architecture.';

  // Build style-specific decoration descriptions with variety
  const styleDescriptions = {
    classic_christmas: {
      exterior: [
        `traditional Christmas elements like warm white or multicolor string lights, wreaths with red bows, red and gold garland, illuminated reindeer, candy cane lights`,
        `timeless holiday decorations including festive string lights, classic wreaths, red ribbons, golden garland, illuminated figures, pathway decorations`,
        `traditional festive touches such as twinkling lights, evergreen wreaths with bows, metallic garland, light-up characters, decorative stakes`,
      ],
      interior: [
        `classic holiday decor including a Christmas tree with red, gold, and green ornaments, garland on mantles, stockings, string lights, poinsettias`,
        `traditional Christmas decorations like an ornament-filled tree, festive garland, holiday stockings, warm lights, seasonal florals, classic accents`,
        `timeless holiday elements such as a decorated tree, ribbon garland, hanging stockings, twinkling lights, red flowers, nostalgic ornaments`,
      ],
      mood: 'warm and traditionally festive',
    },
    nordic_minimalist: {
      exterior: [
        `minimalist Nordic decorations like simple white LED lights, natural pine wreaths, white and wood accents`,
        `Scandinavian-inspired elements including clean white lights, understated natural wreaths, subtle wooden decorations`,
        `minimal Nordic touches such as cool white lights, simple evergreen arrangements, natural materials, geometric shapes`,
      ],
      interior: [
        `Nordic-inspired decor including a natural pine tree with minimal ornaments, white candles, evergreen branches, white textiles, geometric shapes`,
        `Scandinavian minimalist decorations like a simple tree with wooden ornaments, candles in holders, natural greenery, white linens, clean-lined accents`,
        `understated Nordic elements such as a sparse evergreen tree, simple candlelight, natural branches, neutral textiles, minimal geometric ornaments`,
      ],
      mood: 'clean, serene, and understated with Scandinavian simplicity',
    },
    modern_silver: {
      exterior: [
        `modern metallic decorations including cool white LED icicle lights, sleek silver wreaths, illuminated silver spheres, metallic garland`,
        `contemporary silver elements like crisp white lights, modern silver and chrome wreaths, geometric light displays, metallic accents`,
        `elegant modern decor such as LED icicle lights, minimalist silver wreaths, illuminated metallic ornaments, sleek garland`,
      ],
      interior: [
        `modern silver Christmas decorations including a tree with metallic ornaments, geometric decor, cool LED lights, silver garland, chrome accents`,
        `contemporary metallic elements like a sleek tree with silver and white ornaments, modern shapes, cool-toned lights, metallic ribbons, glass accents`,
        `elegant modern decor such as a stylish tree with chrome ornaments, geometric decorations, LED accents, silver garland, reflective elements`,
      ],
      mood: 'elegant, contemporary, and sophisticated',
    },
    cozy_family: {
      exterior: [
        `cozy family decorations including warm amber and multicolor lights, colorful wreaths, illuminated inflatables, light-up characters, playful pathway lights, rustic signs`,
        `welcoming holiday elements like cheerful string lights, festive wreaths, whimsical figures, lighted decorations, candy cane markers, wooden accents`,
        `playful festive decor such as multicolor lights, vibrant wreaths, fun inflatable characters, illuminated yard decorations, festive pathway lights, rustic touches`,
      ],
      interior: [
        `cozy family decorations including a warmly lit tree with colorful ornaments, ambient string lights, plush throws, festive pillows, rustic wood decor, handmade ornaments, stockings`,
        `warm inviting elements like a bright tree with diverse ornaments, glowing string lights, soft textiles, holiday pillows, natural wood pieces, personal touches, hanging stockings`,
        `playful cozy decor such as a cheerful tree with vibrant ornaments, twinkling lights, comfortable throws, festive cushions, wooden decorations, crafted ornaments, traditional stockings`,
      ],
      mood: 'warm, inviting, and playfully festive',
    },
    rustic_farmhouse: {
      exterior: [
        `rustic farmhouse decorations including warm white lights, natural evergreen wreaths with burlap, wooden signs, galvanized metal accents, plaid ribbons, vintage lanterns`,
        `country-style holiday elements like Edison bulb string lights, natural greenery with burlap bows, weathered wood decorations, metal stars, buffalo check patterns, rustic lanterns`,
        `farmhouse festive touches such as warm vintage lights, pine and burlap wreaths, distressed wood signs, barn-style accents, country ribbons, antique lanterns`,
      ],
      interior: [
        `rustic farmhouse Christmas decor including a tree with burlap ribbons and wooden ornaments, galvanized metal accents, plaid textiles, natural greenery, vintage signs, farmhouse stockings`,
        `country holiday decorations like a tree with natural and wooden ornaments, metal containers, buffalo check fabrics, evergreen arrangements, distressed wood pieces, rustic stockings`,
        `farmhouse festive elements such as a tree with burlap and wood accents, vintage metal decor, plaid throws, natural branches, barn-inspired decorations, country stockings`,
      ],
      mood: 'warm, rustic, and authentically country',
    },
    elegant_gold: {
      exterior: [
        `elegant gold decorations including warm white lights, luxurious gold and white wreaths, metallic gold garland, champagne-colored ornaments, sophisticated lighting`,
        `upscale holiday elements like refined white lights, gold and cream wreaths, metallic gold ribbons, elegant ornamental displays, sophisticated accents`,
        `luxurious festive touches such as pristine white lights, gold-adorned wreaths, shimmering gold garland, elegant ornaments, refined decorative elements`,
      ],
      interior: [
        `elegant gold Christmas decorations including a tree with gold, white, and cream ornaments, metallic gold garland, champagne-colored ribbons, luxurious textiles, sophisticated accents`,
        `upscale holiday decor like a refined tree with gold and ivory ornaments, shimmering gold garland, elegant ribbons, plush fabrics, sophisticated decorative pieces`,
        `luxurious festive elements such as a stylish tree with metallic gold and white ornaments, gleaming garland, rich ribbons, elegant textiles, refined accents`,
      ],
      mood: 'elegant, luxurious, and sophisticated',
    },
    colorful_whimsical: {
      exterior: [
        `colorful whimsical decorations including rainbow multicolor lights, bright bold wreaths, playful yard decorations, colorful inflatables, vibrant ribbons, fun character displays`,
        `playful festive elements like cheerful multicolor lights, rainbow wreaths, whimsical figures, bright decorations, colorful accents, fun light-up displays`,
        `vibrant holiday touches such as rainbow string lights, colorful bold wreaths, playful decorative figures, bright inflatables, multicolor ribbons, joyful displays`,
      ],
      interior: [
        `colorful whimsical Christmas decor including a tree with bright multicolor ornaments, rainbow lights, playful decorations, vibrant ribbons, fun patterned textiles, cheerful accents`,
        `playful festive elements like a joyful tree with diverse colorful ornaments, rainbow string lights, whimsical decorations, bright ribbons, fun fabrics, cheerful pieces`,
        `vibrant holiday decorations such as a bright tree with rainbow ornaments, multicolor lights, playful accents, colorful ribbons, bold textiles, fun decorative elements`,
      ],
      mood: 'joyful, vibrant, and playfully festive',
    },
  };

  const styleData = styleDescriptions[style];
  if (!styleData) {
    throw new Error(`Unknown style: ${style}`);
  }

  // Randomly select a variation for more variety
  const variations = isExterior ? styleData.exterior : styleData.interior;
  const selectedVariation = variations[Math.floor(Math.random() * variations.length)];

  // Build the full description
  return `Add ${intensityGuide.coverage} ${selectedVariation}. ${intensityGuide.approach} with ${intensityGuide.quantity}. ${preserve} The result should be ${intensityGuide.descriptor} and ${styleData.mood}.`;
}

/**
 * Generates a Christmas-decorated image using Gemini
 * @param {string} imageBase64 - Base64 encoded image data (without data URL prefix)
 * @param {string} mimeType - Image MIME type (e.g., 'image/jpeg')
 * @param {string} style - Preset style or 'custom'
 * @param {string} scene - 'interior' or 'exterior'
 * @param {string} customPrompt - Custom prompt if style is 'custom'
 * @param {string} lighting - 'day' or 'night' lighting mode
 * @param {string} intensity - Decoration intensity level
 * @returns {Promise<{imageBase64: string, mimeType: string}>}
 */
export async function generateDecoratedImage(
  imageBase64,
  mimeType,
  style,
  scene,
  customPrompt = '',
  lighting = 'day',
  intensity = 'medium'
) {
  try {
    const parts = [
      {
        inlineData: {
          data: imageBase64,
          mimeType: mimeType,
        },
      },
    ];

    // Determine the decoration type based on scene
    const designerType = scene === 'interior'
      ? 'interior designer'
      : 'exterior holiday decorator';

    // Build the prompt
    let basePrompt;
    if (style === 'custom') {
      // Custom prompt with intensity awareness
      const intensityGuide = getIntensityGuidance(intensity);
      const preserve = scene === 'exterior'
        ? 'Maintain the original house architecture and structure.'
        : 'Maintain the original room structure and architecture.';

      basePrompt = `As an expert ${designerType} specializing in Christmas decorations, ${customPrompt}. ${intensityGuide.approach} with ${intensityGuide.quantity} to create a ${intensityGuide.descriptor} look. ${preserve}`;
    } else {
      // Use base style description with intensity
      const styleDescription = getBaseStyleDescription(style, scene, intensity);
      basePrompt = `As an expert ${designerType} specializing in Christmas decorations, ${styleDescription}`;
    }

    // Enhanced lighting mode context
    if (lighting === 'night') {
      basePrompt += `. The scene should be depicted at nighttime with a dark sky. Make all lights from the decorations glow beautifully and luminously in the darkness. Emphasize the warm, glowing ambiance created by the illuminated decorations, with lights casting soft glows and creating a magical nighttime atmosphere. Any string lights, bulbs, or illuminated elements should appear bright and radiant against the dark setting.`;
    } else {
      // Enhanced day mode to make decorations vibrant and visible
      basePrompt += `. Ensure all decorations are vibrant, colorful, and clearly visible in bright daylight. Make the decorations stand out prominently with rich colors and textures that catch the eye.`;
    }

    parts.push({ text: basePrompt });

    console.log('🎨 Generating image with Gemini...');
    console.log(`   Model: gemini-2.5-flash-image`);
    console.log(`   Style: ${style}`);
    console.log(`   Scene: ${scene}`);
    console.log(`   Intensity: ${intensity}`);
    console.log(`   Lighting: ${lighting}`);

    const aiClient = getAIClient();
    const response = await aiClient.models.generateContent({
      model: 'gemini-2.5-flash-image',
      contents: { parts },
      config: {
        responseModalities: [Modality.IMAGE],
      },
    });

    const firstCandidate = response.candidates?.[0];
    if (!firstCandidate) {
      throw new Error('No candidates returned from the API.');
    }

    const imagePart = firstCandidate.content.parts.find(
      (part) => part.inlineData
    );

    if (imagePart && imagePart.inlineData) {
      console.log('✅ Image generated successfully');
      return {
        imageBase64: imagePart.inlineData.data,
        mimeType: imagePart.inlineData.mimeType || 'image/png',
      };
    } else {
      throw new Error('No image data found in the API response.');
    }
  } catch (error) {
    console.error('❌ Gemini API call failed:', error);
    throw new Error(
      'The AI model could not process the request. Please try a different prompt or image.'
    );
  }
}

/**
 * Analyzes generated image and finds similar Christmas decoration products
 * @param {string} base64Image - Base64 encoded image data
 * @param {string} mimeType - Image MIME type
 * @returns {Promise<Array<{productName: string, description: string, searchTerm: string}>>}
 */
export async function findSimilarProducts(base64Image, mimeType = 'image/png') {
  try {
    const prompt = `Analyze this Christmas-decorated space and identify up to 6 distinct decorative items that are clearly visible and suitable for purchase. For each item, provide:
1. A product name (concise and specific)
2. A brief 1-sentence description highlighting key features
3. A concise e-commerce search term that would find this item on Amazon or similar sites

Focus on items like:
- Christmas trees and ornaments
- Lights and string lights
- Garlands and wreaths
- Stockings and decorative pillows
- Figurines and centerpieces
- Other visible holiday decorations

If fewer than 6 clear items are visible, return only those you can clearly identify. If no clear items are visible, return an empty array.`;

    console.log('🔍 Analyzing image for product recommendations...');

    const aiClient = getAIClient();
    const response = await aiClient.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: {
        parts: [
          {
            inlineData: {
              data: base64Image,
              mimeType: mimeType,
            },
          },
          { text: prompt },
        ],
      },
      config: {
        responseMimeType: 'application/json',
        responseSchema: {
          type: Type.ARRAY,
          items: {
            type: Type.OBJECT,
            properties: {
              productName: {
                type: Type.STRING,
                description: 'The name of the product.',
              },
              description: {
                type: Type.STRING,
                description: 'A brief 1-sentence description of the product.',
              },
              searchTerm: {
                type: Type.STRING,
                description: 'A concise search term for an e-commerce site.',
              },
            },
            required: ['productName', 'description', 'searchTerm'],
          },
        },
      },
    });

    const jsonText = response.text.trim();
    if (!jsonText) {
      console.log('⚠️  No products detected in image');
      return [];
    }

    const products = JSON.parse(jsonText);
    console.log(`✅ Found ${products.length} product recommendations`);
    return products;
  } catch (error) {
    console.error('❌ Failed to find similar products:', error);
    // Return empty array on failure so the UI doesn't break
    return [];
  }
}

/**
 * Get style information
 */
export function getStyleInfo(style) {
  return STYLE_PROMPTS[style] || null;
}

/**
 * Get all available styles
 */
export function getAllStyles() {
  return Object.keys(STYLE_PROMPTS).map((key) => ({
    id: key,
    ...STYLE_PROMPTS[key],
  }));
}

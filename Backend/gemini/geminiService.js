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
        `traditional Christmas decorations in warm whites, reds, and golds appropriate for this exterior`,
        `timeless holiday elements in classic red, green, and gold colors that suit this outdoor space`,
        `traditional festive decorations in classic holiday colors fitting for this home's exterior`,
      ],
      interior: [
        `classic Christmas decorations in traditional red, gold, and green colors - choosing items appropriate for this specific room that naturally fit the space`,
        `traditional holiday decor in warm festive colors - selecting room-appropriate seasonal accents and decorative touches`,
        `timeless Christmas elements in classic holiday colors - placing contextually fitting decorations for this room`,
      ],
      mood: 'warm and traditionally festive',
    },
    nordic_minimalist: {
      exterior: [
        `minimalist Nordic Christmas decorations in whites and natural wood tones for this exterior`,
        `Scandinavian-inspired holiday elements with restraint suited to this outdoor space`,
        `minimal Nordic festive touches in neutral tones appropriate for this home's exterior`,
      ],
      interior: [
        `Nordic-inspired Christmas decor with Scandinavian minimalism - selecting room-appropriate items in whites and natural materials that fit this specific space`,
        `Scandinavian minimalist holiday decorations in whites and naturals - choosing contextually fitting elements with clean lines`,
        `understated Nordic Christmas elements with restraint - placing appropriate decorations suited to this room`,
      ],
      mood: 'clean, serene, and understated with Scandinavian simplicity',
    },
    modern_silver: {
      exterior: [
        `modern metallic Christmas decorations in cool whites and silvers for this exterior`,
        `contemporary silver holiday elements with clean lines suited to this outdoor space`,
        `elegant modern festive decor in silvers and whites appropriate for this home's exterior`,
      ],
      interior: [
        `modern silver Christmas decorations with contemporary style - selecting room-appropriate metallic and geometric elements that naturally fit this specific space`,
        `contemporary metallic holiday elements in silvers and whites - choosing contextually fitting decorations with modern aesthetics`,
        `elegant modern Christmas decor with clean lines - placing appropriate sophisticated metallic touches suited to this room`,
      ],
      mood: 'elegant, contemporary, and sophisticated',
    },
    cozy_family: {
      exterior: [
        `cozy family Christmas decorations in warm colors and playful styles for this exterior`,
        `warm inviting holiday elements with playful touches suited to this outdoor space`,
        `playful festive outdoor decor in warm tones appropriate for this home's exterior`,
      ],
      interior: [
        `cozy family Christmas decorations in warm, inviting colors - selecting room-appropriate items that naturally fit this specific space`,
        `warm inviting holiday elements with personal touches - choosing contextually fitting decorations with cozy aesthetics`,
        `playful cozy Christmas decor in vibrant warm tones - placing appropriate comfortable and cheerful elements suited to this room`,
      ],
      mood: 'warm, inviting, and playfully festive',
    },
    rustic_farmhouse: {
      exterior: [
        `rustic farmhouse Christmas decorations in natural materials and warm tones for this exterior`,
        `country-style holiday elements with authentic farmhouse charm suited to this outdoor space`,
        `farmhouse festive decor with rustic textures appropriate for this home's exterior`,
      ],
      interior: [
        `rustic farmhouse Christmas decor with natural textures - selecting room-appropriate items that naturally fit this specific space`,
        `country holiday decorations with authentic farmhouse style - choosing contextually fitting elements with rustic charm`,
        `farmhouse festive elements with rustic charm - placing appropriate natural and vintage-inspired touches suited to this room`,
      ],
      mood: 'warm, rustic, and authentically country',
    },
    elegant_gold: {
      exterior: [
        `elegant gold Christmas decorations in luxurious metallics and creams for this exterior`,
        `upscale holiday elements in golds and ivories suited to this outdoor space`,
        `luxurious festive decor in champagne and gold tones appropriate for this home's exterior`,
      ],
      interior: [
        `elegant gold Christmas decorations in luxurious metallics - selecting room-appropriate items that naturally fit this specific space`,
        `upscale holiday decor in golds, creams, and ivories - choosing contextually fitting elements with sophisticated aesthetics`,
        `luxurious festive elements in champagne and gold - placing appropriate refined and elegant touches suited to this room`,
      ],
      mood: 'elegant, luxurious, and sophisticated',
    },
  };

  const styleData = styleDescriptions[style];
  if (!styleData) {
    throw new Error(`Unknown style: ${style}`);
  }

  // Randomly select a variation for more variety
  const variations = isExterior ? styleData.exterior : styleData.interior;
  const selectedVariation = variations[Math.floor(Math.random() * variations.length)];

  // Add contextual awareness for interior spaces
  const contextGuidance = isExterior
    ? ''
    : ' Analyze the room type and function in the image, then select decorations that make sense for that specific space - for example, festive table settings and centerpieces for dining rooms, countertop decorations and kitchen towels for kitchens, subtle accents for bathrooms, cozy textiles and ambient decorations for bedrooms, and traditional decorations for living rooms. Avoid adding large items like Christmas trees in spaces where they would not naturally fit or be practical.';

  // Build the full description
  return `Add ${intensityGuide.coverage} ${selectedVariation}. ${intensityGuide.approach} with ${intensityGuide.quantity}.${contextGuidance} ${preserve} The result should be ${intensityGuide.descriptor} and ${styleData.mood}.`;
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
  console.log('🎨 generateDecoratedImage called with:', {
    style,
    scene,
    intensity,
    lighting,
    mimeType,
    imageSize: imageBase64?.length || 0,
    hasCustomPrompt: !!customPrompt
  });

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
      // Custom prompt with intensity awareness and contextual guidance
      const intensityGuide = getIntensityGuidance(intensity);
      const preserve = scene === 'exterior'
        ? 'Maintain the original house architecture and structure.'
        : 'Maintain the original room structure and architecture.';

      const contextGuidance = scene === 'exterior'
        ? ''
        : ' Analyze the room type and function in the image, then select decorations that make sense for that specific space - for example, festive table settings and centerpieces for dining rooms, countertop decorations and kitchen towels for kitchens, subtle accents for bathrooms, cozy textiles and ambient decorations for bedrooms. Avoid adding large items like Christmas trees in spaces where they would not naturally fit or be practical.';

      basePrompt = `As an expert ${designerType} specializing in Christmas decorations, ${customPrompt}. ${intensityGuide.approach} with ${intensityGuide.quantity} to create a ${intensityGuide.descriptor} look.${contextGuidance} ${preserve}`;
    } else {
      // Use base style description with intensity
      const styleDescription = getBaseStyleDescription(style, scene, intensity);
      basePrompt = `As an expert ${designerType} specializing in Christmas decorations, ${styleDescription}`;
    }

    // Enhanced lighting mode context
    if (lighting === 'night') {
      basePrompt += ` The final image should depict the scene at night with a dark sky, making any lights from the decorations glow beautifully and luminously in the darkness. Emphasize the warm, glowing ambiance created by the illuminated decorations, with lights casting soft glows and creating a magical nighttime atmosphere. Any string lights, bulbs, or illuminated elements should appear bright and radiant against the dark setting.`;
    } else {
      // Enhanced day mode to make decorations vibrant and visible
      basePrompt += ` The final image should depict the scene in bright daylight. Ensure all decorations are vibrant, colorful, and clearly visible with rich colors and textures that catch the eye.`;
    }

    parts.push({ text: basePrompt });

    console.log('📝 Prompt being sent to Gemini:', basePrompt.substring(0, 200) + '...');
    console.log('🚀 Calling Gemini API...');

    const aiClient = getAIClient();
    const response = await aiClient.models.generateContent({
      model: 'gemini-2.5-flash-image',
      contents: { parts },
      config: {
        responseModalities: [Modality.IMAGE],
      },
    });

    console.log('✅ Gemini API response received:', {
      hasCandidates: !!response.candidates,
      candidatesLength: response.candidates?.length,
      firstCandidateHasContent: !!response.candidates?.[0]?.content
    });

    const firstCandidate = response.candidates?.[0];
    if (!firstCandidate) {
      throw new Error('No candidates returned from the API.');
    }

    const contentParts = firstCandidate.content?.parts;
    if (!contentParts || contentParts.length === 0) {
      throw new Error('Candidate content missing from API response.');
    }

    const imagePart = contentParts.find(
      (part) => part.inlineData
    );

    if (imagePart && imagePart.inlineData) {
      return {
        imageBase64: imagePart.inlineData.data,
        mimeType: imagePart.inlineData.mimeType || 'image/png',
      };
    } else {
      throw new Error('No image data found in the API response.');
    }
  } catch (error) {
    console.error('❌ Gemini API call failed!');
    console.error('Error name:', error.name);
    console.error('Error message:', error.message);
    console.error('Error code:', error.code);
    console.error('Error status:', error.status);
    console.error('Error stack:', error.stack);

    // Log the full error object
    console.error('Full error object:', JSON.stringify(error, Object.getOwnPropertyNames(error), 2));

    // If there's a response from the API, log it
    if (error.response) {
      console.error('API Response:', JSON.stringify(error.response, null, 2));
    }

    // Re-throw with original error details
    throw error;
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
      return [];
    }

    const products = JSON.parse(jsonText);
    return products;
  } catch (error) {
    if (process.env.NODE_ENV !== 'production') {
      console.error('❌ Failed to find similar products:', error);
    }
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

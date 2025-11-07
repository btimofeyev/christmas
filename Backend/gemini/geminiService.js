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
        `traditional Christmas decorations in warm whites, reds, and golds - including string lights, wreaths with bows, garland, and seasonal outdoor accents appropriate for this exterior`,
        `timeless holiday elements in classic red, green, and gold colors - such as festive lighting, wreaths, ribbons, and decorative touches that suit this outdoor space`,
        `traditional festive decorations featuring warm lights, evergreen wreaths, metallic accents, and classic seasonal elements fitting for this home's exterior`,
      ],
      interior: [
        `classic Christmas decorations in traditional red, gold, and green colors - choosing items appropriate for this specific room such as festive textiles, garland, string lights, seasonal accents, and decorative pieces that naturally fit the space`,
        `traditional holiday decor in warm festive colors - selecting room-appropriate items like holiday linens, garland swags, twinkling lights, seasonal florals, and classic ornamental touches`,
        `timeless Christmas elements in classic holiday colors - placing contextually fitting decorations such as festive fabrics, ribbon accents, warm lighting, and traditional seasonal pieces`,
      ],
      mood: 'warm and traditionally festive',
    },
    nordic_minimalist: {
      exterior: [
        `minimalist Nordic Christmas decorations in whites and natural wood tones - simple LED lights, understated wreaths, and clean-lined seasonal accents for this exterior`,
        `Scandinavian-inspired holiday elements with restraint - cool white lights, natural evergreen touches, and minimal wooden accents suited to this outdoor space`,
        `minimal Nordic festive touches in neutral tones - simple lighting, natural wreaths, and geometric shapes appropriate for this home's exterior`,
      ],
      interior: [
        `Nordic-inspired Christmas decor with Scandinavian minimalism - selecting room-appropriate items like white candles, minimal evergreen branches, natural textiles, and understated geometric accents that fit this specific space`,
        `Scandinavian minimalist holiday decorations in whites and naturals - choosing contextually fitting elements such as simple candlelight, natural greenery, neutral linens, and clean-lined seasonal touches`,
        `understated Nordic Christmas elements with restraint - placing appropriate decorations like sparse natural branches, minimal candlelight, white textiles, and geometric ornaments suited to this room`,
      ],
      mood: 'clean, serene, and understated with Scandinavian simplicity',
    },
    modern_silver: {
      exterior: [
        `modern metallic Christmas decorations in cool whites and silvers - sleek LED lights, contemporary wreaths, and geometric seasonal accents for this exterior`,
        `contemporary silver holiday elements with clean lines - crisp white lighting, modern metallic wreaths, and minimalist decorative touches suited to this outdoor space`,
        `elegant modern festive decor in silvers and whites - LED icicle lights, sleek wreaths, and geometric ornamental accents appropriate for this home's exterior`,
      ],
      interior: [
        `modern silver Christmas decorations with contemporary style - selecting room-appropriate items like metallic accents, geometric decor, cool LED lighting, and sleek ornamental pieces that naturally fit this specific space`,
        `contemporary metallic holiday elements in silvers and whites - choosing contextually fitting decorations such as modern ornamental accents, geometric shapes, cool-toned lights, and reflective elements`,
        `elegant modern Christmas decor with clean lines - placing appropriate items like chrome accents, minimalist geometric pieces, LED lighting, and sophisticated metallic touches suited to this room`,
      ],
      mood: 'elegant, contemporary, and sophisticated',
    },
    cozy_family: {
      exterior: [
        `cozy family Christmas decorations in warm colors and playful styles - welcoming lights, cheerful wreaths, whimsical figures, and festive accents for this exterior`,
        `warm inviting holiday elements with playful touches - multicolor string lights, vibrant wreaths, fun seasonal figures, and rustic accents suited to this outdoor space`,
        `playful festive outdoor decor in warm tones - cheerful lighting, colorful wreaths, whimsical decorative characters, and welcoming seasonal touches appropriate for this home's exterior`,
      ],
      interior: [
        `cozy family Christmas decorations in warm, inviting colors - selecting room-appropriate items like ambient lighting, plush textiles, festive pillows, rustic wood accents, and cheerful ornamental touches that naturally fit this specific space`,
        `warm inviting holiday elements with personal touches - choosing contextually fitting decorations such as soft throws, holiday cushions, glowing string lights, natural wood pieces, and handmade seasonal accents`,
        `playful cozy Christmas decor in vibrant warm tones - placing appropriate items like comfortable textiles, festive fabrics, twinkling lights, wooden decorations, and cheerful ornamental pieces suited to this room`,
      ],
      mood: 'warm, inviting, and playfully festive',
    },
    rustic_farmhouse: {
      exterior: [
        `rustic farmhouse Christmas decorations in natural materials and warm tones - vintage-style lights, evergreen wreaths with burlap, wooden signs, and country accents for this exterior`,
        `country-style holiday elements with authentic farmhouse charm - Edison bulb lights, natural greenery with rustic bows, weathered wood pieces, and barn-inspired touches suited to this outdoor space`,
        `farmhouse festive decor with rustic textures - warm vintage lighting, natural wreaths, distressed wood signs, and country seasonal accents appropriate for this home's exterior`,
      ],
      interior: [
        `rustic farmhouse Christmas decor with natural textures - selecting room-appropriate items like burlap accents, wooden ornamental pieces, galvanized metal containers, plaid textiles, natural greenery, and vintage-inspired decorations that naturally fit this specific space`,
        `country holiday decorations with authentic farmhouse style - choosing contextually fitting elements such as natural and wooden accents, metal containers, buffalo check fabrics, evergreen arrangements, and distressed wood pieces`,
        `farmhouse festive elements with rustic charm - placing appropriate items like burlap and wood accents, vintage metal decor, plaid throws, natural branches, and barn-inspired seasonal touches suited to this room`,
      ],
      mood: 'warm, rustic, and authentically country',
    },
    elegant_gold: {
      exterior: [
        `elegant gold Christmas decorations in luxurious metallics and creams - refined warm white lights, gold-adorned wreaths, sophisticated garland, and upscale seasonal accents for this exterior`,
        `upscale holiday elements in golds and ivories - pristine white lighting, luxurious metallic wreaths, elegant ribbons, and refined decorative touches suited to this outdoor space`,
        `luxurious festive decor in champagne and gold tones - sophisticated lighting, gold-embellished wreaths, shimmering garland, and elegant ornamental accents appropriate for this home's exterior`,
      ],
      interior: [
        `elegant gold Christmas decorations in luxurious metallics - selecting room-appropriate items like gold ornamental accents, metallic garland, champagne-colored textiles, plush fabrics, and sophisticated decorative pieces that naturally fit this specific space`,
        `upscale holiday decor in golds, creams, and ivories - choosing contextually fitting elements such as refined metallic accents, shimmering garland, elegant ribbons, luxurious textiles, and sophisticated ornamental touches`,
        `luxurious festive elements in champagne and gold - placing appropriate items like gleaming metallic accents, rich ribbons, elegant textiles, gold ornamental pieces, and refined decorative touches suited to this room`,
      ],
      mood: 'elegant, luxurious, and sophisticated',
    },
    colorful_whimsical: {
      exterior: [
        `colorful whimsical Christmas decorations in bright, joyful hues - rainbow multicolor lights, bold vibrant wreaths, playful seasonal figures, and fun festive accents for this exterior`,
        `playful festive elements in rainbow colors - cheerful multicolor lighting, bright bold wreaths, whimsical decorative characters, and vibrant seasonal touches suited to this outdoor space`,
        `vibrant holiday decor in bold, joyful colors - rainbow string lights, colorful wreaths, playful figures, and cheerful festive accents appropriate for this home's exterior`,
      ],
      interior: [
        `colorful whimsical Christmas decor in bright, playful hues - selecting room-appropriate items like vibrant textiles, rainbow lighting, fun patterned fabrics, cheerful ornamental accents, and bold decorative pieces that naturally fit this specific space`,
        `playful festive elements in rainbow colors - choosing contextually fitting decorations such as bright ribbons, multicolor lights, fun fabrics, whimsical accents, and joyful ornamental touches`,
        `vibrant holiday decorations in bold, cheerful colors - placing appropriate items like colorful textiles, rainbow accents, playful ornamental pieces, bright ribbons, and fun decorative elements suited to this room`,
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
      basePrompt += `. The scene should be depicted at nighttime with a dark sky. Make all lights from the decorations glow beautifully and luminously in the darkness. Emphasize the warm, glowing ambiance created by the illuminated decorations, with lights casting soft glows and creating a magical nighttime atmosphere. Any string lights, bulbs, or illuminated elements should appear bright and radiant against the dark setting.`;
    } else {
      // Enhanced day mode to make decorations vibrant and visible
      basePrompt += `. Ensure all decorations are vibrant, colorful, and clearly visible in bright daylight. Make the decorations stand out prominently with rich colors and textures that catch the eye.`;
    }

    parts.push({ text: basePrompt });

    if (process.env.NODE_ENV !== 'production') {
      console.log('🎨 Generating image with Gemini...');
      console.log(`   Model: gemini-2.5-flash-image`);
      console.log(`   Style: ${style}`);
      console.log(`   Scene: ${scene}`);
      console.log(`   Intensity: ${intensity}`);
      console.log(`   Lighting: ${lighting}`);
    }

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
      return {
        imageBase64: imagePart.inlineData.data,
        mimeType: imagePart.inlineData.mimeType || 'image/png',
      };
    } else {
      throw new Error('No image data found in the API response.');
    }
  } catch (error) {
    if (process.env.NODE_ENV !== 'production') {
      console.error('❌ Gemini API call failed:', error);
    }
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

/**
 * Validates the incoming request for image generation
 */
export function validateGenerateRequest(body) {
  const errors = [];

  // Check required fields
  if (!body.scene) {
    errors.push('scene is required');
  } else if (!['interior', 'exterior'].includes(body.scene)) {
    errors.push('scene must be either "interior" or "exterior"');
  }

  if (!body.style) {
    errors.push('style is required');
  } else if (!['classic_christmas', 'nordic_minimalist', 'modern_silver', 'cozy_family', 'rustic_farmhouse', 'elegant_gold', 'colorful_whimsical', 'custom'].includes(body.style)) {
    errors.push('Invalid style. Must be one of: classic_christmas, nordic_minimalist, modern_silver, cozy_family, rustic_farmhouse, elegant_gold, colorful_whimsical, custom');
  }

  if (body.style === 'custom' && !body.prompt) {
    errors.push('prompt is required when style is "custom"');
  }

  // Validate intensity parameter
  if (body.intensity && !['minimal', 'light', 'medium', 'heavy', 'maximal'].includes(body.intensity)) {
    errors.push('Invalid intensity. Must be one of: minimal, light, medium, heavy, maximal');
  }

  if (!body.image_base64) {
    errors.push('image_base64 is required');
  } else if (!body.image_base64.startsWith('data:image/')) {
    errors.push('image_base64 must be a valid data URL');
  }

  return {
    valid: errors.length === 0,
    errors
  };
}

/**
 * Extracts base64 data from data URL
 */
export function extractBase64(dataUrl) {
  const matches = dataUrl.match(/^data:image\/\w+;base64,(.+)$/);
  return matches ? matches[1] : null;
}

/**
 * Gets MIME type from data URL
 */
export function getMimeType(dataUrl) {
  const matches = dataUrl.match(/^data:(image\/\w+);base64,/);
  return matches ? matches[1] : 'image/jpeg';
}

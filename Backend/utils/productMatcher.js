/**
 * Product Matcher Utility
 *
 * Matches AI-generated product recommendations to real Amazon products
 * Uses smart matching based on:
 * - Category similarity
 * - Style matching
 * - Price range compatibility
 * - Tag overlap
 */

/**
 * Match AI product recommendation to real products
 *
 * @param {Object} aiProduct - AI-generated product from Gemini
 * @param {Array} realProducts - Array of real Amazon products
 * @param {string} style - Current decoration style
 * @returns {Object|null} Best matching product or null
 */
export function matchProduct(aiProduct, realProducts, style) {
  if (!aiProduct || !realProducts || realProducts.length === 0) {
    return null;
  }

  const searchTerm = aiProduct.searchTerm.toLowerCase();
  const scores = realProducts.map(product => ({
    product,
    score: calculateMatchScore(searchTerm, product, style)
  }));

  // Sort by score (highest first)
  scores.sort((a, b) => b.score - a.score);

  // Return best match if score is good enough
  const bestMatch = scores[0];
  return bestMatch.score >= 30 ? bestMatch.product : null;
}

/**
 * Calculate match score between AI search term and real product
 */
function calculateMatchScore(searchTerm, product, style) {
  let score = 0;

  const productName = product.name.toLowerCase();
  const productTags = product.tags || [];

  // 1. Exact keyword matches (high weight)
  const searchWords = searchTerm.split(' ').filter(w => w.length > 3);
  searchWords.forEach(word => {
    if (productName.includes(word)) {
      score += 15;
    }
  });

  // 2. Category matches (using tags)
  const categoryKeywords = extractCategoryKeywords(searchTerm);
  categoryKeywords.forEach(keyword => {
    if (productTags.includes(keyword) || productName.includes(keyword)) {
      score += 20;
    }
  });

  // 3. Style compatibility
  if (isStyleCompatible(style, productTags, productName)) {
    score += 10;
  }

  // 4. Rating bonus (high-quality products)
  if (product.rating >= 4.5) {
    score += 5;
  }
  if (product.reviewCount >= 1000) {
    score += 5;
  }

  // 5. Price range diversity bonus
  // Prefer varied prices to show options
  if (product.priceRange === 'premium') {
    score += 3; // Slightly favor premium (higher commission)
  }

  return score;
}

/**
 * Extract category keywords from search term
 */
function extractCategoryKeywords(searchTerm) {
  const keywords = [];
  const term = searchTerm.toLowerCase();

  // Category detection
  if (term.includes('tree')) keywords.push('christmas-tree', 'trees');
  if (term.includes('ornament')) keywords.push('ornaments');
  if (term.includes('light')) keywords.push('lights');
  if (term.includes('garland')) keywords.push('garland');
  if (term.includes('wreath')) keywords.push('wreath');
  if (term.includes('stocking')) keywords.push('stockings');
  if (term.includes('decoration')) keywords.push('decorations');

  // Material/style detection
  if (term.includes('wood')) keywords.push('wooden', 'rustic');
  if (term.includes('metal')) keywords.push('metal', 'modern');
  if (term.includes('led') || term.includes('lights')) keywords.push('lights', 'illumination');

  // Color detection
  if (term.includes('red')) keywords.push('red');
  if (term.includes('gold')) keywords.push('gold');
  if (term.includes('silver')) keywords.push('silver');
  if (term.includes('white')) keywords.push('white');
  if (term.includes('green')) keywords.push('green');

  return keywords;
}

/**
 * Check if product style matches decoration style
 */
function isStyleCompatible(decorStyle, productTags, productName) {
  const name = productName.toLowerCase();
  const tags = productTags.map(t => t.toLowerCase());

  switch (decorStyle) {
    case 'classic_christmas':
      return tags.includes('traditional') ||
             tags.includes('classic') ||
             name.includes('traditional') ||
             name.includes('classic') ||
             tags.includes('red') ||
             tags.includes('gold');

    case 'nordic_minimalist':
      return tags.includes('minimalist') ||
             tags.includes('scandinavian') ||
             tags.includes('natural') ||
             name.includes('minimalist') ||
             name.includes('natural') ||
             name.includes('white') ||
             tags.includes('white');

    case 'modern_silver':
      return tags.includes('modern') ||
             tags.includes('contemporary') ||
             tags.includes('silver') ||
             name.includes('modern') ||
             name.includes('contemporary') ||
             name.includes('led');

    case 'cozy_family':
      return tags.includes('rustic') ||
             tags.includes('farmhouse') ||
             tags.includes('cozy') ||
             name.includes('rustic') ||
             name.includes('warm');

    default:
      return true; // Custom style - accept all
  }
}

/**
 * Match multiple AI products to real products
 * Ensures diversity in selections (no duplicates, varied prices)
 */
export function matchMultipleProducts(aiProducts, allProducts, style, maxResults = 6) {
  const matches = [];
  const usedASINs = new Set();

  for (const aiProduct of aiProducts) {
    const match = matchProduct(aiProduct, allProducts, style);

    if (match && !usedASINs.has(match.asin)) {
      matches.push(match);
      usedASINs.add(match.asin);

      if (matches.length >= maxResults) {
        break;
      }
    }
  }

  // If we don't have enough matches, fill with top-rated products
  if (matches.length < 4) {
    const remaining = allProducts
      .filter(p => !usedASINs.has(p.asin))
      .sort((a, b) => b.rating - a.rating)
      .slice(0, 4 - matches.length);

    matches.push(...remaining);
  }

  return matches;
}

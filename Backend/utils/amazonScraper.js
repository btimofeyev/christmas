/**
 * Amazon Product Scraper Utility
 *
 * Scrapes Amazon for Christmas decoration products
 * Extracts: ASIN, name, price, image, rating, reviews
 */

import axios from 'axios';
import * as cheerio from 'cheerio';

// User agents to rotate (avoid blocking)
const USER_AGENTS = [
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
];

/**
 * Fetch HTML from Amazon with rate limiting
 */
export async function fetchAmazonPage(url, retries = 3) {
  for (let i = 0; i < retries; i++) {
    try {
      // Random delay between requests (1-3 seconds)
      await delay(1000 + Math.random() * 2000);

      const response = await axios.get(url, {
        headers: {
          'User-Agent': USER_AGENTS[Math.floor(Math.random() * USER_AGENTS.length)],
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1'
        },
        timeout: 10000
      });

      return response.data;
    } catch (error) {
      console.error(`❌ Attempt ${i + 1} failed:`, error.message);
      if (i === retries - 1) throw error;
      await delay(3000); // Wait longer before retry
    }
  }
}

/**
 * Extract product ASIN from various formats
 */
export function extractASIN(urlOrElement) {
  if (typeof urlOrElement === 'string') {
    const match = urlOrElement.match(/\/dp\/([A-Z0-9]{10})|\/gp\/product\/([A-Z0-9]{10})/);
    return match ? (match[1] || match[2]) : null;
  }
  return null;
}

/**
 * Parse price from Amazon format
 */
export function parsePrice(priceText) {
  if (!priceText) return null;

  // Remove all non-numeric characters except decimal point
  const cleanPrice = priceText.replace(/[^0-9.]/g, '');
  const price = parseFloat(cleanPrice);

  return isNaN(price) ? null : `$${price.toFixed(2)}`;
}

/**
 * Extract rating (e.g., "4.7 out of 5 stars")
 */
export function parseRating(ratingText) {
  if (!ratingText) return null;

  const match = ratingText.match(/(\d+\.?\d*)\s*out of/);
  return match ? parseFloat(match[1]) : null;
}

/**
 * Extract review count
 */
export function parseReviewCount(reviewText) {
  if (!reviewText) return 0;

  const cleanCount = reviewText.replace(/[^0-9]/g, '');
  return parseInt(cleanCount) || 0;
}

/**
 * Scrape Amazon Best Sellers page for a category
 */
export async function scrapeAmazonBestSellers(categoryUrl, maxProducts = 8) {
  console.log(`\n🔍 Scraping: ${categoryUrl}`);

  const html = await fetchAmazonPage(categoryUrl);
  const $ = cheerio.load(html);
  const products = [];

  // Amazon Best Sellers uses different selectors
  $('.zg-grid-general-faceout').each((index, element) => {
    if (products.length >= maxProducts) return false;

    const $el = $(element);

    // Extract product link and ASIN
    const link = $el.find('a.a-link-normal').first().attr('href');
    if (!link) return;

    const asin = extractASIN(link);
    if (!asin) return;

    // Extract product name
    const name = $el.find('.p13n-sc-truncate').text().trim() ||
                 $el.find('._cDEzb_p13n-sc-css-line-clamp-3_g3dy1').text().trim();

    // Extract price
    const priceText = $el.find('.a-price .a-offscreen').first().text().trim() ||
                      $el.find('.p13n-sc-price').text().trim();
    const price = parsePrice(priceText);

    // Extract rating
    const ratingText = $el.find('.a-icon-alt').text();
    const rating = parseRating(ratingText);

    // Extract review count
    const reviewText = $el.find('.a-size-small').text();
    const reviewCount = parseReviewCount(reviewText);

    // Extract image
    const image = $el.find('img').attr('src');

    if (name && price && image) {
      products.push({
        asin,
        name,
        price,
        image: cleanImageUrl(image),
        rating: rating || 4.5,
        reviewCount: reviewCount || 1000,
        link: `https://www.amazon.com/dp/${asin}`
      });
    }
  });

  console.log(`✅ Found ${products.length} products`);
  return products;
}

/**
 * Clean and enhance Amazon image URL for higher quality
 */
function cleanImageUrl(url) {
  if (!url) return null;

  // Replace low-res with high-res
  return url.replace(/_AC_.*?\./, '_AC_SL1500_.');
}

/**
 * Delay helper
 */
function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Generate product tags based on name
 */
export function generateTags(productName) {
  const tags = [];
  const lowerName = productName.toLowerCase();

  // Category tags
  if (lowerName.includes('tree')) tags.push('christmas-tree', 'trees');
  if (lowerName.includes('ornament')) tags.push('ornaments', 'decorations');
  if (lowerName.includes('light')) tags.push('lights', 'illumination');
  if (lowerName.includes('garland')) tags.push('garland', 'greenery');
  if (lowerName.includes('wreath')) tags.push('wreath', 'door-decor');
  if (lowerName.includes('stocking')) tags.push('stockings', 'accessories');

  // Style tags
  if (lowerName.includes('traditional') || lowerName.includes('classic')) {
    tags.push('traditional', 'classic');
  }
  if (lowerName.includes('modern') || lowerName.includes('contemporary')) {
    tags.push('modern', 'contemporary');
  }
  if (lowerName.includes('rustic') || lowerName.includes('farmhouse')) {
    tags.push('rustic', 'farmhouse');
  }

  // Color tags
  if (lowerName.includes('red')) tags.push('red');
  if (lowerName.includes('gold')) tags.push('gold');
  if (lowerName.includes('silver')) tags.push('silver');
  if (lowerName.includes('white')) tags.push('white');
  if (lowerName.includes('green')) tags.push('green');

  return tags;
}

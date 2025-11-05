/**
 * Update products.json with real Amazon product images
 * Fetches actual product images from Amazon search results
 */

import fs from 'fs';
import path from 'path';
import axios from 'axios';
import * as cheerio from 'cheerio';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PRODUCTS_PATH = path.join(__dirname, '../data/products.json');

// User agents for rotation
const USER_AGENTS = [
  'Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
];

function delay(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Fetch first product image from Amazon search
 */
async function fetchAmazonProductImage(searchTerm) {
  try {
    const searchUrl = `https://www.amazon.com/s?k=${encodeURIComponent(searchTerm)}`;

    console.log(`  🔍 Searching: ${searchTerm}`);

    await delay(2000 + Math.random() * 2000); // 2-4 second delay

    const response = await axios.get(searchUrl, {
      headers: {
        'User-Agent': USER_AGENTS[Math.floor(Math.random() * USER_AGENTS.length)],
        'Accept': 'text/html,application/xhtml+xml',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1'
      },
      timeout: 10000
    });

    const $ = cheerio.load(response.data);

    // Try multiple selectors for product images
    let imageUrl = null;

    // Selector 1: Main product image
    imageUrl = $('img.s-image').first().attr('src');

    // Selector 2: Backup selector
    if (!imageUrl) {
      imageUrl = $('div[data-component-type="s-search-result"] img').first().attr('src');
    }

    // Selector 3: Another backup
    if (!imageUrl) {
      imageUrl = $('.s-result-item img').first().attr('src');
    }

    if (imageUrl) {
      // Clean up the image URL to get high-res version
      imageUrl = imageUrl.replace(/_AC_.*?\./g, '_AC_SL1000.');
      console.log(`  ✅ Found image: ${imageUrl.substring(0, 60)}...`);
      return imageUrl;
    } else {
      console.log(`  ❌ No image found for: ${searchTerm}`);
      return null;
    }
  } catch (error) {
    console.log(`  ⚠️  Error: ${error.message}`);
    return null;
  }
}

/**
 * Main function to update all product images
 */
async function updateProductImages() {
  console.log('🖼️  Updating product images with real Amazon photos...\n');

  // Read current products
  const productsData = JSON.parse(fs.readFileSync(PRODUCTS_PATH, 'utf8'));

  // Create backup
  const backupPath = PRODUCTS_PATH.replace('.json', '-backup-images.json');
  fs.writeFileSync(backupPath, JSON.stringify(productsData, null, 2));
  console.log(`💾 Backup created: ${backupPath}\n`);

  let totalProducts = 0;
  let updatedProducts = 0;

  // Process each style
  for (const [style, products] of Object.entries(productsData)) {
    console.log(`📦 Processing ${style}...`);

    for (const product of products) {
      totalProducts++;

      // Extract search term from existing Amazon link
      const match = product.link.match(/k=([^&]+)/);
      if (!match) {
        console.log(`  ⚠️  ${product.name} - No search term in link`);
        continue;
      }

      const searchTerm = decodeURIComponent(match[1]);
      const imageUrl = await fetchAmazonProductImage(searchTerm);

      if (imageUrl) {
        product.image = imageUrl;
        updatedProducts++;
      }
    }

    console.log('');
  }

  // Save updated products
  fs.writeFileSync(PRODUCTS_PATH, JSON.stringify(productsData, null, 2));

  console.log('✅ Complete!');
  console.log(`   Total products: ${totalProducts}`);
  console.log(`   Images updated: ${updatedProducts}`);
  console.log(`   Failed: ${totalProducts - updatedProducts}\n`);
  console.log('💡 Products saved to:', PRODUCTS_PATH);

  if (updatedProducts === 0) {
    console.log('\n⚠️  Amazon may be blocking requests. Consider:');
    console.log('   1. Running script again later');
    console.log('   2. Using a VPN');
    console.log('   3. Manually adding image URLs from Amazon product pages');
  }
}

// Run the script
updateProductImages().catch(console.error);

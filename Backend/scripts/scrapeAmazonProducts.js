/**
 * Amazon Product Scraper - Christmas Decorations
 *
 * Scrapes Amazon Best Sellers for Christmas products
 * Organizes by style: classic, nordic, modern, cozy
 * Price range: $10 - $500+ (no limits)
 *
 * Usage: npm run scrape-products
 */

import { scrapeAmazonBestSellers, generateTags } from '../utils/amazonScraper.js';
import { writeFile, readFile } from 'fs/promises';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Amazon Best Sellers URLs for Christmas categories
const CATEGORIES = {
  classic_christmas: [
    'https://www.amazon.com/Best-Sellers-Christmas-Trees/zgbs/home-garden/3734931',
    'https://www.amazon.com/Best-Sellers-Christmas-Ornaments/zgbs/home-garden/3734851'
  ],
  nordic_minimalist: [
    'https://www.amazon.com/Best-Sellers-Christmas-Wreaths/zgbs/home-garden/3734881',
    'https://www.amazon.com/Best-Sellers-Holiday-Candles/zgbs/home-garden/3734891'
  ],
  modern_silver: [
    'https://www.amazon.com/Best-Sellers-Christmas-Lights/zgbs/home-garden/3734841',
    'https://www.amazon.com/Best-Sellers-Christmas-Ornaments/zgbs/home-garden/3734851'
  ],
  cozy_family: [
    'https://www.amazon.com/Best-Sellers-Christmas-Stockings/zgbs/home-garden/3734871',
    'https://www.amazon.com/Best-Sellers-Christmas-Tree-Toppers/zgbs/home-garden/3734861'
  ],
  custom: [
    'https://www.amazon.com/Best-Sellers-Christmas-Decorations/zgbs/home-garden/3734831'
  ]
};

/**
 * Main scraping function
 */
async function scrapeAllProducts() {
  console.log('🎄 Starting Amazon Product Scraper...\n');
  console.log('📦 Scraping Christmas decorations across all price ranges\n');

  const allProducts = {};
  const affiliateTag = process.env.AMAZON_AFFILIATE_TAG || 'homedesignai-20';

  for (const [style, urls] of Object.entries(CATEGORIES)) {
    console.log(`\n🎨 Scraping style: ${style}`);
    allProducts[style] = [];

    for (const url of urls) {
      try {
        const products = await scrapeAmazonBestSellers(url, 4);

        // Add affiliate tag and additional fields
        const enhancedProducts = products.map(product => ({
          ...product,
          link: `${product.link}?tag=${affiliateTag}`,
          tags: generateTags(product.name),
          priceRange: categorizePriceRange(product.price),
          lastUpdated: new Date().toISOString().split('T')[0]
        }));

        allProducts[style].push(...enhancedProducts);
      } catch (error) {
        console.error(`❌ Failed to scrape ${url}:`, error.message);
      }
    }

    // Deduplicate by ASIN
    allProducts[style] = deduplicateByASIN(allProducts[style]);

    // Sort by rating (highest first)
    allProducts[style].sort((a, b) => b.rating - a.rating);

    // Limit to top 6 per style
    allProducts[style] = allProducts[style].slice(0, 6);

    console.log(`✅ ${style}: ${allProducts[style].length} products`);
  }

  return allProducts;
}

/**
 * Categorize price range for filtering
 */
function categorizePriceRange(priceStr) {
  const price = parseFloat(priceStr.replace('$', ''));

  if (price < 20) return 'budget';
  if (price < 50) return 'affordable';
  if (price < 150) return 'mid-range';
  return 'premium';
}

/**
 * Remove duplicate products by ASIN
 */
function deduplicateByASIN(products) {
  const seen = new Set();
  return products.filter(product => {
    if (seen.has(product.asin)) return false;
    seen.add(product.asin);
    return true;
  });
}

/**
 * Save products to JSON file
 */
async function saveProducts(products) {
  const productsPath = join(__dirname, '../data/products.json');
  const backupPath = join(__dirname, '../data/products-backup.json');

  try {
    // Backup existing products
    try {
      const existing = await readFile(productsPath, 'utf-8');
      await writeFile(backupPath, existing);
      console.log('\n💾 Backed up existing products.json');
    } catch (error) {
      // No existing file, that's fine
    }

    // Save new products
    await writeFile(productsPath, JSON.stringify(products, null, 2));
    console.log('✅ Saved new products.json\n');

    // Print summary
    let totalProducts = 0;
    let totalValue = 0;

    console.log('📊 Summary:\n');
    for (const [style, styleProducts] of Object.entries(products)) {
      const count = styleProducts.length;
      const avgRating = (styleProducts.reduce((sum, p) => sum + p.rating, 0) / count).toFixed(1);
      const prices = styleProducts.map(p => parseFloat(p.price.replace('$', '')));
      const minPrice = Math.min(...prices);
      const maxPrice = Math.max(...prices);

      console.log(`  ${style}:`);
      console.log(`    Products: ${count}`);
      console.log(`    Avg Rating: ${avgRating}★`);
      console.log(`    Price Range: $${minPrice.toFixed(2)} - $${maxPrice.toFixed(2)}`);

      totalProducts += count;
      totalValue += prices.reduce((a, b) => a + b, 0);
    }

    console.log(`\n  TOTAL: ${totalProducts} products`);
    console.log(`  Avg Product Value: $${(totalValue / totalProducts).toFixed(2)}`);
    console.log(`  Affiliate Tag: ${process.env.AMAZON_AFFILIATE_TAG || 'homedesignai-20'}`);

  } catch (error) {
    console.error('❌ Failed to save products:', error);
    throw error;
  }
}

/**
 * Run the scraper
 */
async function main() {
  try {
    const products = await scrapeAllProducts();
    await saveProducts(products);

    console.log('\n🎉 Scraping complete!');
    console.log('👉 Products saved to: Backend/data/products.json\n');
    console.log('⚠️  Remember to restart your backend server to load new products\n');
  } catch (error) {
    console.error('\n❌ Scraping failed:', error);
    process.exit(1);
  }
}

main();

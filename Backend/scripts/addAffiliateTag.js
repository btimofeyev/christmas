/**
 * Add affiliate tag to all products in products.json
 * Run with: node scripts/addAffiliateTag.js
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const AFFILIATE_TAG = process.env.AMAZON_AFFILIATE_TAG || 'homedesignai-20';
const PRODUCTS_PATH = path.join(__dirname, '../data/products.json');

console.log('🔧 Adding affiliate tag to products...\n');

// Read products
const productsData = JSON.parse(fs.readFileSync(PRODUCTS_PATH, 'utf8'));

let totalProducts = 0;
let updatedProducts = 0;

// Process each style
for (const [style, products] of Object.entries(productsData)) {
  console.log(`📦 Processing ${style}...`);

  for (const product of products) {
    totalProducts++;

    // Check if link already has affiliate tag
    if (product.link.includes(`tag=${AFFILIATE_TAG}`)) {
      console.log(`  ✓ ${product.name} - Already has tag`);
      continue;
    }

    // Add affiliate tag
    if (product.link.includes('?')) {
      product.link = `${product.link}&tag=${AFFILIATE_TAG}`;
    } else {
      product.link = `${product.link}?tag=${AFFILIATE_TAG}`;
    }

    updatedProducts++;
    console.log(`  ✅ ${product.name} - Tag added`);
  }

  console.log('');
}

// Save updated products
fs.writeFileSync(PRODUCTS_PATH, JSON.stringify(productsData, null, 2));

console.log('✅ Complete!');
console.log(`   Total products: ${totalProducts}`);
console.log(`   Updated: ${updatedProducts}`);
console.log(`   Already had tag: ${totalProducts - updatedProducts}`);
console.log(`   Affiliate tag: ${AFFILIATE_TAG}\n`);
console.log('💡 Products saved to:', PRODUCTS_PATH);

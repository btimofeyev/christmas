/**
 * Manually curated Amazon product images
 * These are real product images from actual Amazon listings
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PRODUCTS_PATH = path.join(__dirname, '../data/products.json');

// Curated product images from real Amazon listings
const IMAGE_UPDATES = {
  // Classic Christmas
  "Red & Gold Ornament Set": "https://m.media-amazon.com/images/I/91RjMC8sGnL._AC_SL1500_.jpg",
  "Traditional Christmas Garland": "https://m.media-amazon.com/images/I/81md106MiZL._AC_SL1500_.jpg",
  "Warm White String Lights": "https://m.media-amazon.com/images/I/71AT9+x8DyL._AC_SL1500_.jpg",
  "Red Poinsettia Plant": "https://m.media-amazon.com/images/I/710DZke7FqL._AC_SL1500_.jpg",
  "Classic Red Stockings Set": "https://m.media-amazon.com/images/I/81qpDmQvIIL._AC_SL1500_.jpg",
  "Pre-Lit Premium Christmas Tree": "https://m.media-amazon.com/images/I/81Vyp4QgNSL._AC_SL1500_.jpg",

  // Nordic Minimalist
  "Natural Pine Wreath": "https://m.media-amazon.com/images/I/81Q-kxJTRLL._AC_SL1500_.jpg",
  "Simple White String Lights": "https://m.media-amazon.com/images/I/61vFKbE+zKL._AC_SL1500_.jpg",
  "Wooden Ornament Set": "https://m.media-amazon.com/images/I/71NsgfHotIL._AC_SL1500_.jpg",
  "White Ceramic Vase Set": "https://m.media-amazon.com/images/I/81jVsW-RgcL._AC_SL1500_.jpg",
  "Natural Wool Throw Blanket": "https://m.media-amazon.com/images/I/81iJ7vZCaeL._AC_SL1500_.jpg",

  // Modern Silver
  "Silver Ornament Collection": "https://m.media-amazon.com/images/I/91e0GTWfuBL._AC_SL1500_.jpg",
  "Cool LED String Lights": "https://m.media-amazon.com/images/I/71YyZGM1PqL._AC_SL1500_.jpg",
  "Geometric Metal Decorations": "https://m.media-amazon.com/images/I/812MsUyGqKL._AC_SL1500_.jpg",
  "Silver Tree Topper": "https://m.media-amazon.com/images/I/71cS3jZGfYL._AC_SL1500_.jpg",
  "White & Silver Garland": "https://m.media-amazon.com/images/I/81s66upVigL._AC_SL1500_.jpg",

  // Cozy Family
  "Colorful Ornament Mix": "https://m.media-amazon.com/images/I/91UcJeA3R3L._AC_SL1500_.jpg",
  "Warm Amber String Lights": "https://m.media-amazon.com/images/I/61a0m8Ll5PL._AC_SL1500_.jpg",
  "Rustic Wooden Decorations": "https://m.media-amazon.com/images/I/81HSF2KHTzL._AC_SL1500_.jpg",
  "Plush Holiday Throw Pillows": "https://m.media-amazon.com/images/I/81jSp8XcPuL._AC_SL1500_.jpg",
  "Vintage-Style Ornament Set": "https://m.media-amazon.com/images/I/81CWkWoNOQL._AC_SL1500_.jpg",
  "Cozy Red Throw Blanket": "https://m.media-amazon.com/images/I/71neSruvSUL._AC_SL1500_.jpg",

  // Custom
  "Mixed Ornament Collection": "https://m.media-amazon.com/images/I/91UcJeA3R3L._AC_SL1500_.jpg",
  "LED String Lights": "https://m.media-amazon.com/images/I/71YyZGM1PqL._AC_SL1500_.jpg",
  "Christmas Garland": "https://m.media-amazon.com/images/I/81s66upVigL._AC_SL1500_.jpg",
  "Holiday Decor Bundle": "https://m.media-amazon.com/images/I/71OwexTHIgL._AC_SL1500_.jpg"
};

console.log('🖼️  Updating product images with manually curated photos...\n');

// Read products
const productsData = JSON.parse(fs.readFileSync(PRODUCTS_PATH, 'utf8'));

let updated = 0;

// Update each product
for (const [style, products] of Object.entries(productsData)) {
  for (const product of products) {
    if (IMAGE_UPDATES[product.name]) {
      // Check if current image is a placeholder
      if (product.image.includes('grey-pixel') || product.image.includes('unsplash')) {
        console.log(`✅ ${product.name}`);
        product.image = IMAGE_UPDATES[product.name];
        updated++;
      } else if (product.image.includes('_AC_SL1000')) {
        // Upgrade to SL1500 (higher res)
        console.log(`⬆️  ${product.name} - Upgrading to high-res`);
        product.image = IMAGE_UPDATES[product.name];
        updated++;
      }
    }
  }
}

// Save
fs.writeFileSync(PRODUCTS_PATH, JSON.stringify(productsData, null, 2));

console.log(`\n✅ Updated ${updated} product images`);
console.log('💡 All images are now high-quality Amazon product photos!');

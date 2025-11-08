import { readFile } from 'fs/promises';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { query } from '../db/database.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

/**
 * Migrates existing referral data from JSON file to Postgres database
 */
async function migrateData() {
  console.log('🔄 Starting migration from JSON to Postgres...\n');

  try {
    // Read existing referrals.json file
    const referralsPath = join(__dirname, '../data/referrals.json');
    const jsonData = await readFile(referralsPath, 'utf-8');
    const referrals = JSON.parse(jsonData);

    console.log('📄 Read referrals.json:');
    console.log(`   - ${Object.keys(referrals.codes).length} referral codes`);
    console.log(`   - ${referrals.claims.length} claims\n`);

    let migratedUsers = 0;
    let migratedReferrals = 0;
    let migratedClaims = 0;

    // Migrate referral codes and their owners
    for (const [code, data] of Object.entries(referrals.codes)) {
      console.log(`Migrating referral code: ${code}`);

      // Create user if doesn't exist
      await query(
        `INSERT INTO users (device_id, generations_remaining, total_generated)
         VALUES ($1, 3, 0)
         ON CONFLICT (device_id) DO NOTHING`,
        [data.deviceId]
      );
      migratedUsers++;

      // Insert referral code
      await query(
        `INSERT INTO referrals (code, device_id, total_claims, created_at)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (code) DO NOTHING`,
        [code, data.deviceId, data.totalClaims || 0, data.createdAt]
      );
      migratedReferrals++;

      console.log(`   ✅ Created user and referral for device: ${data.deviceId}`);
    }

    // Migrate claims
    for (const claim of referrals.claims) {
      console.log(`Migrating claim: ${claim.code} by ${claim.claimerDeviceId}`);

      // Create claimer user if doesn't exist
      await query(
        `INSERT INTO users (device_id, generations_remaining, total_generated)
         VALUES ($1, 3, 0)
         ON CONFLICT (device_id) DO NOTHING`,
        [claim.claimerDeviceId]
      );

      // Insert claim
      await query(
        `INSERT INTO claims (code, claimer_device_id, claimed_at)
         VALUES ($1, $2, $3)
         ON CONFLICT DO NOTHING`,
        [claim.code, claim.claimerDeviceId, claim.claimedAt]
      );
      migratedClaims++;

      console.log(`   ✅ Created claim`);
    }

    console.log('\n✅ Migration completed successfully!');
    console.log(`   - Migrated ${migratedUsers} users`);
    console.log(`   - Migrated ${migratedReferrals} referral codes`);
    console.log(`   - Migrated ${migratedClaims} claims`);

    // Verify migration
    console.log('\n📊 Verifying data in database...');
    const userCount = await query('SELECT COUNT(*) FROM users');
    const referralCount = await query('SELECT COUNT(*) FROM referrals');
    const claimCount = await query('SELECT COUNT(*) FROM claims');

    console.log(`   - Users in DB: ${userCount.rows[0].count}`);
    console.log(`   - Referrals in DB: ${referralCount.rows[0].count}`);
    console.log(`   - Claims in DB: ${claimCount.rows[0].count}`);

    process.exit(0);

  } catch (error) {
    console.error('\n❌ Migration failed:', error);
    console.error(error.stack);
    process.exit(1);
  }
}

// Run migration
migrateData();

import pkg from 'pg';
const { Pool } = pkg;
import dotenv from 'dotenv';

// Load environment variables (needed for local development)
dotenv.config();

// Debug: Check if DATABASE_URL is loaded
if (process.env.DATABASE_URL) {
  console.log('🔧 Database module: DATABASE_URL loaded successfully');
} else {
  console.log('⚠️  Database module: DATABASE_URL is NOT set!');
}

// Initialize connection pool
// DATABASE_URL is automatically injected by Railway
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  // Railway Postgres requires SSL even for external connections
  ssl: process.env.DATABASE_URL ? {
    rejectUnauthorized: false
  } : false
});

// Test connection on startup
pool.on('connect', () => {
  console.log('✅ Connected to PostgreSQL database');
});

pool.on('error', (err) => {
  console.error('❌ Unexpected error on idle client', err);
  process.exit(-1);
});

const ensurePurchaseTransactionsTable = async () => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS purchase_transactions (
        transaction_id VARCHAR(255) PRIMARY KEY,
        device_id VARCHAR(255) NOT NULL,
        product_id VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Ensured purchase_transactions table exists');
  } catch (error) {
    console.error('❌ Failed to ensure purchase_transactions table exists', error);
  }
};

ensurePurchaseTransactionsTable();

/**
 * Execute a SQL query
 * @param {string} text - SQL query
 * @param {Array} params - Query parameters
 * @returns {Promise} Query result
 */
export const query = async (text, params) => {
  const start = Date.now();
  try {
    const res = await pool.query(text, params);
    const duration = Date.now() - start;

    if (process.env.NODE_ENV !== 'production') {
      console.log('🔍 Executed query', { text, duration, rows: res.rowCount });
    }

    return res;
  } catch (error) {
    console.error('❌ Database query error:', error);
    throw error;
  }
};

/**
 * Get or create a user by device_id
 * @param {string} deviceId
 * @returns {Promise<Object>} User object
 */
export const getOrCreateUser = async (deviceId) => {
  const result = await query(
    `INSERT INTO users (device_id, generations_remaining, total_generated)
     VALUES ($1, 3, 0)
     ON CONFLICT (device_id) DO UPDATE SET updated_at = CURRENT_TIMESTAMP
     RETURNING *`,
    [deviceId]
  );
  return result.rows[0];
};

/**
 * Update user's generation count
 * @param {string} deviceId
 * @param {number} generationsRemaining
 * @param {number} totalGenerated
 */
export const updateUserGenerations = async (deviceId, generationsRemaining, totalGenerated) => {
  await query(
    `UPDATE users
     SET generations_remaining = $1,
         total_generated = $2,
         updated_at = CURRENT_TIMESTAMP
     WHERE device_id = $3`,
    [generationsRemaining, totalGenerated, deviceId]
  );
};

/**
 * Get user by device_id
 * @param {string} deviceId
 * @returns {Promise<Object|null>} User object or null
 */
export const getUserByDeviceId = async (deviceId) => {
  const result = await query(
    'SELECT * FROM users WHERE device_id = $1',
    [deviceId]
  );
  return result.rows[0] || null;
};

export const getUnprocessedTransactions = async (transactionIds) => {
  if (!transactionIds || transactionIds.length === 0) {
    return [];
  }

  const result = await query(
    'SELECT transaction_id FROM purchase_transactions WHERE transaction_id = ANY($1::text[])',
    [transactionIds]
  );

  const processed = new Set(result.rows.map((row) => row.transaction_id));
  return transactionIds.filter((id) => !processed.has(id));
};

export const recordProcessedTransactions = async (deviceId, productId, transactionIds) => {
  if (!transactionIds || transactionIds.length === 0) {
    return;
  }

  const values = transactionIds
    .map((_, index) => `($${index * 3 + 1}, $${index * 3 + 2}, $${index * 3 + 3})`)
    .join(', ');

  const params = transactionIds.flatMap((id) => [id, deviceId, productId]);

  await query(
    `INSERT INTO purchase_transactions (transaction_id, device_id, product_id)
     VALUES ${values}
     ON CONFLICT (transaction_id) DO NOTHING`,
    params
  );
};

// Named exports for direct use
export { pool };

// Default export with all functions
export default {
  query,
  getOrCreateUser,
  updateUserGenerations,
  getUserByDeviceId,
  getUnprocessedTransactions,
  recordProcessedTransactions,
  pool
};

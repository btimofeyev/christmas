import pkg from 'pg';
const { Pool } = pkg;

// Initialize connection pool
// DATABASE_URL is automatically injected by Railway
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? {
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

export default {
  query,
  getOrCreateUser,
  updateUserGenerations,
  getUserByDeviceId,
  pool
};

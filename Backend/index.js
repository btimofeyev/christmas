// Load environment variables FIRST (before any imports that need them)
import dotenv from 'dotenv';
dotenv.config();

// Now import everything else
import express from 'express';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';
import generateRouter from './routes/generate.js';
import subscribeRouter from './routes/subscribe.js';
import referralRouter from './routes/referral.js';
import contactRouter from './routes/contact.js';
import { pool } from './db/database.js';

const app = express();
const PORT = process.env.PORT || 3000;

// Get __dirname equivalent in ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Log ALL incoming requests BEFORE CORS (so we can see blocked requests too)
app.use((req, res, next) => {
  console.log('🌐 Incoming request:', {
    method: req.method,
    path: req.path,
    origin: req.headers.origin || 'NO ORIGIN HEADER',
    userAgent: req.headers['user-agent'],
    contentType: req.headers['content-type']
  });
  next();
});

// Middleware
const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',')
  : ['capacitor://localhost', 'ionic://localhost'];

console.log('🔒 CORS Configuration:', {
  allowedOrigins,
  fromEnv: !!process.env.ALLOWED_ORIGINS
});

app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) {
      console.log('✅ CORS: Allowing request with no origin');
      return callback(null, true);
    }

    if (allowedOrigins.includes(origin)) {
      console.log('✅ CORS: Allowing origin:', origin);
      callback(null, true);
    } else {
      console.error('❌ CORS: Blocking origin:', origin);
      console.error('   Allowed origins:', allowedOrigins);
      callback(new Error('Not allowed by CORS'));
    }
  },
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type']
}));

app.use(express.json({ limit: '10mb' })); // Allow larger payloads for base64 images
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Log requests in development only
if (process.env.NODE_ENV !== 'production') {
  app.use((req, res, next) => {
    console.log(`📨 ${req.method} ${req.path}`);
    next();
  });
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'HolidayHome AI Backend',
    timestamp: new Date().toISOString()
  });
});

// API Routes (MUST come before static files!)
app.use('/generate', generateRouter);
app.use('/subscribe', subscribeRouter);
app.use('/referral', referralRouter);
app.use('/contact', contactRouter);

// Referral landing page route
app.get('/r/:code', (req, res) => {
  const code = req.params.code;
  res.sendFile(path.join(__dirname, '../public/r.html'));
});

// Explicit routes for legal pages
app.get('/privacy', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/privacy.html'));
});

app.get('/terms', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/terms.html'));
});

app.get('/contact', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/contact.html'));
});

// Serve static files from public directory (fallback - comes AFTER API routes)
const publicPath = path.join(__dirname, '../public');
app.use(express.static(publicPath));

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : 'An error occurred'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Start server
app.listen(PORT, async () => {
  console.log(`🎄 HomeDesign AI Backend running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);

  // Test database connection
  console.log('\n🔍 Checking database connection...');
  if (!process.env.DATABASE_URL) {
    console.error('❌ DATABASE_URL environment variable is not set!');
    console.error('   The app will fail when trying to generate images or use referrals.');
    console.error('   Please set DATABASE_URL in Railway dashboard.');
  } else {
    console.log('✅ DATABASE_URL is set:', process.env.DATABASE_URL.substring(0, 30) + '...');
    try {
      const result = await pool.query('SELECT NOW()');
      console.log('✅ Database connection successful!');
      console.log(`   Connected at: ${result.rows[0].now}`);
    } catch (error) {
      console.error('❌ Database connection failed!');
      console.error('   Error message:', error.message || 'No error message');
      console.error('   Error code:', error.code);
      console.error('   Full error:', error);
      console.error('   The app will not work properly.');
    }
  }
  console.log('');
});

export default app;

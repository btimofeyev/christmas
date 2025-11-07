import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import generateRouter from './routes/generate.js';
import subscribeRouter from './routes/subscribe.js';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Get __dirname equivalent in ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Middleware
app.use(cors({
  origin: '*', // For development - restrict in production
  methods: ['GET', 'POST'],
  allowedHeaders: ['Content-Type']
}));

app.use(express.json({ limit: '10mb' })); // Allow larger payloads for base64 images
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Log all incoming requests for debugging
app.use((req, res, next) => {
  console.log(`📨 ${req.method} ${req.path} - Headers: ${JSON.stringify(req.headers)}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'HolidayHome AI Backend',
    timestamp: new Date().toISOString()
  });
});

// API Routes (MUST come before static files!)
console.log('🔧 Registering API routes...');
app.use('/generate', generateRouter);
app.use('/subscribe', subscribeRouter);
console.log('✅ API routes registered: /generate, /subscribe');

// Serve static files from public directory (fallback - comes AFTER API routes)
const publicPath = path.join(__dirname, '../public');
console.log(`📁 Static files path: ${publicPath}`);
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
app.listen(PORT, () => {
  console.log(`\n${'='.repeat(60)}`);
  console.log(`🎄 HolidayHome AI Backend running on port ${PORT}`);
  console.log(`${'='.repeat(60)}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
  console.log(`🎨 Generate endpoint: http://localhost:${PORT}/generate`);
  console.log(`📧 Subscribe endpoint: http://localhost:${PORT}/subscribe`);
  console.log(`📁 Serving static files from: ${publicPath}`);
  console.log(`${'='.repeat(60)}\n`);
});

export default app;

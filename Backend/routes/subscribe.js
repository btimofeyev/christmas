import express from 'express';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const router = express.Router();
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Email validation regex
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

/**
 * POST /subscribe
 * Collects email addresses for main app beta access
 */
router.post('/', async (req, res) => {
  try {
    const { email, source = 'christmas_app' } = req.body;

    // Validate email
    if (!email || typeof email !== 'string') {
      return res.status(400).json({
        error: 'Email is required',
        message: 'Please provide a valid email address'
      });
    }

    const trimmedEmail = email.trim().toLowerCase();

    if (!EMAIL_REGEX.test(trimmedEmail)) {
      return res.status(400).json({
        error: 'Invalid email format',
        message: 'Please enter a valid email address'
      });
    }

    // Prepare subscriber data
    const subscriber = {
      email: trimmedEmail,
      source,
      subscribedAt: new Date().toISOString(),
      userAgent: req.headers['user-agent'] || 'unknown'
    };

    // Store email in JSON file (simple storage for MVP)
    const emailsFilePath = path.join(__dirname, '../data/subscribers.json');

    let subscribers = [];
    try {
      const fileContent = await fs.readFile(emailsFilePath, 'utf-8');
      subscribers = JSON.parse(fileContent);
    } catch (error) {
      // File doesn't exist yet, start with empty array
      if (process.env.NODE_ENV !== 'production') {
        console.log('📧 Creating new subscribers file');
      }
    }

    // Check for duplicate
    const existingSubscriber = subscribers.find(s => s.email === trimmedEmail);
    if (existingSubscriber) {
      return res.status(200).json({
        success: true,
        message: "You're already on the list!",
        alreadySubscribed: true
      });
    }

    // Add new subscriber
    subscribers.push(subscriber);

    // Save to file
    await fs.writeFile(emailsFilePath, JSON.stringify(subscribers, null, 2));

    if (process.env.NODE_ENV !== 'production') {
      console.log(`✅ New subscriber: ${trimmedEmail} (Total: ${subscribers.length})`);
    }

    res.status(201).json({
      success: true,
      message: "You're on the list! We'll notify you when the full app launches.",
      alreadySubscribed: false
    });

  } catch (error) {
    if (process.env.NODE_ENV !== 'production') {
      console.error('❌ Subscribe error:', error);
    }
    res.status(500).json({
      error: 'Subscription failed',
      message: 'Unable to process your request. Please try again.'
    });
  }
});


export default router;

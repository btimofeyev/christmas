import express from 'express';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import crypto from 'crypto';

const router = express.Router();
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const REFERRALS_FILE = path.join(__dirname, '../data/referrals.json');

// Referral base URL - configurable via environment variable
const REFERRAL_BASE_URL = process.env.REFERRAL_BASE_URL || 'https://holidayhomeai.up.railway.app/r/';

// Initialize referrals data structure
const initializeReferralsFile = async () => {
  try {
    await fs.access(REFERRALS_FILE);
  } catch {
    // File doesn't exist, create it
    const initialData = {
      codes: {},      // { code: { deviceId, createdAt, totalClaims } }
      claims: []      // [{ code, claimerDeviceId, claimedAt }]
    };
    await fs.writeFile(REFERRALS_FILE, JSON.stringify(initialData, null, 2));
  }
};

// Read referrals data
const readReferrals = async () => {
  await initializeReferralsFile();
  const data = await fs.readFile(REFERRALS_FILE, 'utf8');
  return JSON.parse(data);
};

// Write referrals data
const writeReferrals = async (data) => {
  await fs.writeFile(REFERRALS_FILE, JSON.stringify(data, null, 2));
};

// Generate unique 6-character referral code
const generateReferralCode = () => {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Removed ambiguous characters (0,O,1,I)
  let code = '';
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(crypto.randomInt(0, chars.length));
  }
  return code;
};

// POST /generate-referral
// Generate a unique referral code for a user
router.post('/generate-referral', async (req, res) => {
  try {
    const { deviceId } = req.body;

    if (!deviceId) {
      return res.status(400).json({
        error: 'Device ID is required'
      });
    }

    const referrals = await readReferrals();

    // Check if this device already has a code
    const existingCode = Object.keys(referrals.codes).find(
      code => referrals.codes[code].deviceId === deviceId
    );

    if (existingCode) {
      return res.json({
        code: existingCode,
        shareUrl: `${REFERRAL_BASE_URL}${existingCode}`,
        message: 'Existing referral code returned'
      });
    }

    // Generate new unique code
    let newCode;
    let attempts = 0;
    do {
      newCode = generateReferralCode();
      attempts++;
      if (attempts > 10) {
        throw new Error('Failed to generate unique referral code');
      }
    } while (referrals.codes[newCode]);

    // Store new code
    referrals.codes[newCode] = {
      deviceId,
      createdAt: new Date().toISOString(),
      totalClaims: 0
    };

    await writeReferrals(referrals);

    res.json({
      code: newCode,
      shareUrl: `${REFERRAL_BASE_URL}${newCode}`,
      message: 'Referral code generated successfully'
    });

  } catch (error) {
    console.error('Error generating referral:', error);
    res.status(500).json({
      error: 'Failed to generate referral code',
      details: error.message
    });
  }
});

// POST /claim-referral
// Claim a referral code (used when new user installs via referral link)
router.post('/claim-referral', async (req, res) => {
  try {
    const { code, claimerDeviceId } = req.body;

    if (!code || !claimerDeviceId) {
      return res.status(400).json({
        error: 'Code and claimer device ID are required'
      });
    }

    const referrals = await readReferrals();

    // Validate referral code exists
    if (!referrals.codes[code]) {
      return res.status(404).json({
        error: 'Invalid referral code'
      });
    }

    const referralData = referrals.codes[code];

    // Check if user is trying to claim their own code
    if (referralData.deviceId === claimerDeviceId) {
      return res.status(400).json({
        error: 'Cannot claim your own referral code'
      });
    }

    // Check if this device has already claimed this code
    const alreadyClaimed = referrals.claims.some(
      claim => claim.code === code && claim.claimerDeviceId === claimerDeviceId
    );

    if (alreadyClaimed) {
      return res.status(400).json({
        error: 'You have already claimed this referral code'
      });
    }

    // Record the claim
    referrals.claims.push({
      code,
      claimerDeviceId,
      claimedAt: new Date().toISOString()
    });

    // Increment total claims for this code
    referrals.codes[code].totalClaims += 1;

    await writeReferrals(referrals);

    res.json({
      success: true,
      message: 'Referral claimed successfully',
      reward: {
        claimer: 3,    // New user gets +3 generations
        referrer: 3    // Original user gets +3 generations
      },
      referrerDeviceId: referralData.deviceId
    });

  } catch (error) {
    console.error('Error claiming referral:', error);
    res.status(500).json({
      error: 'Failed to claim referral',
      details: error.message
    });
  }
});

// GET /referral-stats/:code
// Get statistics for a referral code (optional - for future analytics)
router.get('/referral-stats/:code', async (req, res) => {
  try {
    const { code } = req.params;
    const referrals = await readReferrals();

    if (!referrals.codes[code]) {
      return res.status(404).json({
        error: 'Referral code not found'
      });
    }

    const codeData = referrals.codes[code];
    const claims = referrals.claims.filter(claim => claim.code === code);

    res.json({
      code,
      createdAt: codeData.createdAt,
      totalClaims: codeData.totalClaims,
      claims: claims.map(c => ({
        claimedAt: c.claimedAt
        // Don't expose device IDs for privacy
      }))
    });

  } catch (error) {
    console.error('Error fetching referral stats:', error);
    res.status(500).json({
      error: 'Failed to fetch referral statistics'
    });
  }
});

export default router;

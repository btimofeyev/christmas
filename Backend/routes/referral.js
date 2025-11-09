import express from 'express';
import crypto from 'crypto';
import { query, getOrCreateUser, updateUserGenerations } from '../db/database.js';

const router = express.Router();

// Referral base URL - configurable via environment variable
const REFERRAL_BASE_URL = process.env.REFERRAL_BASE_URL || 'https://holidayhomeai.up.railway.app/r/';

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

    // Ensure user exists in database
    await getOrCreateUser(deviceId);

    // Check if this device already has a code
    const existingResult = await query(
      'SELECT code FROM referrals WHERE device_id = $1',
      [deviceId]
    );

    if (existingResult.rows.length > 0) {
      const existingCode = existingResult.rows[0].code;
      return res.json({
        code: existingCode,
        shareUrl: `${REFERRAL_BASE_URL}${existingCode}`,
        message: 'Existing referral code returned'
      });
    }

    // Generate new unique code
    let newCode;
    let attempts = 0;
    let codeExists = true;

    while (codeExists && attempts < 10) {
      newCode = generateReferralCode();
      const checkResult = await query(
        'SELECT code FROM referrals WHERE code = $1',
        [newCode]
      );
      codeExists = checkResult.rows.length > 0;
      attempts++;
    }

    if (attempts >= 10) {
      throw new Error('Failed to generate unique referral code');
    }

    // Store new code
    await query(
      'INSERT INTO referrals (code, device_id, total_claims) VALUES ($1, $2, 0)',
      [newCode, deviceId]
    );

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

    // Validate referral code exists
    const referralResult = await query(
      'SELECT * FROM referrals WHERE code = $1',
      [code]
    );

    if (referralResult.rows.length === 0) {
      return res.status(404).json({
        error: 'Invalid referral code'
      });
    }

    const referralData = referralResult.rows[0];

    // Check if user is trying to claim their own code
    if (referralData.device_id === claimerDeviceId) {
      return res.status(400).json({
        error: 'Cannot claim your own referral code'
      });
    }

    // Check if this device has already claimed this code
    const claimCheck = await query(
      'SELECT * FROM claims WHERE code = $1 AND claimer_device_id = $2',
      [code, claimerDeviceId]
    );

    if (claimCheck.rows.length > 0) {
      return res.status(400).json({
        error: 'You have already claimed this referral code'
      });
    }

    // Ensure both users exist in database
    const claimer = await getOrCreateUser(claimerDeviceId);
    const referrer = await getOrCreateUser(referralData.device_id);

    // Record the claim
    await query(
      'INSERT INTO claims (code, claimer_device_id) VALUES ($1, $2)',
      [code, claimerDeviceId]
    );

    // Increment total claims for this code
    await query(
      'UPDATE referrals SET total_claims = total_claims + 1 WHERE code = $1',
      [code]
    );

    // Award +3 generations to both claimer and referrer
    const claimerReward = 3;
    const referrerReward = 3;

    await updateUserGenerations(
      claimerDeviceId,
      claimer.generations_remaining + claimerReward,
      claimer.total_generated
    );

    await updateUserGenerations(
      referralData.device_id,
      referrer.generations_remaining + referrerReward,
      referrer.total_generated
    );

    res.json({
      success: true,
      message: 'Referral claimed successfully',
      reward: {
        claimer: claimerReward,
        referrer: referrerReward
      },
      referrerDeviceId: referralData.device_id
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
// Get statistics for a referral code
router.get('/referral-stats/:code', async (req, res) => {
  try {
    const { code } = req.params;

    const referralResult = await query(
      'SELECT * FROM referrals WHERE code = $1',
      [code]
    );

    if (referralResult.rows.length === 0) {
      return res.status(404).json({
        error: 'Referral code not found'
      });
    }

    const codeData = referralResult.rows[0];

    const claimsResult = await query(
      'SELECT claimed_at FROM claims WHERE code = $1',
      [code]
    );

    res.json({
      code,
      createdAt: codeData.created_at,
      totalClaims: codeData.total_claims,
      claims: claimsResult.rows.map(c => ({
        claimedAt: c.claimed_at
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

// GET /user/:deviceId
// Get or create user and return current generation counts
router.get('/user/:deviceId', async (req, res) => {
  try {
    const { deviceId } = req.params;

    if (!deviceId) {
      return res.status(400).json({
        error: 'Device ID is required'
      });
    }

    // Get or create user
    const user = await getOrCreateUser(deviceId);

    res.json({
      generationsRemaining: user.generations_remaining,
      totalGenerated: user.total_generated,
      deviceId: user.device_id
    });

  } catch (error) {
    console.error('Error fetching user data:', error);
    res.status(500).json({
      error: 'Failed to fetch user data'
    });
  }
});

// GET /stats/:deviceId
// Get user's referral stats by device ID
router.get('/stats/:deviceId', async (req, res) => {
  try {
    const { deviceId } = req.params;

    // Get user's referral code
    const referralResult = await query(
      'SELECT code, total_claims, created_at FROM referrals WHERE device_id = $1',
      [deviceId]
    );

    if (referralResult.rows.length === 0) {
      return res.status(404).json({
        error: 'No referral code found for this device',
        hasCode: false
      });
    }

    const referralData = referralResult.rows[0];

    // Get user's generation stats
    const userResult = await query(
      'SELECT generations_remaining, total_generated FROM users WHERE device_id = $1',
      [deviceId]
    );

    const userData = userResult.rows[0] || { generations_remaining: 0, total_generated: 0 };

    // Calculate designs earned from referrals (3 per referral claimed)
    const designsEarnedFromReferrals = referralData.total_claims * 3;

    res.json({
      hasCode: true,
      code: referralData.code,
      shareUrl: `${REFERRAL_BASE_URL}${referralData.code}`,
      totalReferrals: referralData.total_claims,
      designsEarnedFromReferrals,
      generationsRemaining: userData.generations_remaining,
      totalGenerated: userData.total_generated,
      createdAt: referralData.created_at
    });

  } catch (error) {
    console.error('Error fetching user stats:', error);
    res.status(500).json({
      error: 'Failed to fetch user statistics'
    });
  }
});

export default router;

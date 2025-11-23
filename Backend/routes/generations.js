import express from 'express';
import {
  getOrCreateUser,
  updateUserGenerations,
  getUnprocessedTransactions,
  recordProcessedTransactions
} from '../db/database.js';

const router = express.Router();

const PRODUCT_CREDIT_MAP = {
  holiday_basic_pack: Number(process.env.HOLIDAY_PACK_BONUS || 10)
};

router.post('/credit', async (req, res) => {
  const { deviceId, productId, transactionIds = [] } = req.body;

  if (!deviceId || typeof deviceId !== 'string') {
    return res.status(400).json({
      error: 'Invalid deviceId',
      details: ['deviceId is required']
    });
  }

  if (!productId || typeof productId !== 'string') {
    return res.status(400).json({
      error: 'Invalid productId',
      details: ['productId is required']
    });
  }

  const creditPerTransaction = PRODUCT_CREDIT_MAP[productId];
  if (!creditPerTransaction) {
    return res.status(400).json({
      error: 'Unsupported productId',
      details: [`No credit mapping configured for product ${productId}`]
    });
  }

  if (!Array.isArray(transactionIds) || transactionIds.length === 0) {
    return res.status(400).json({
      error: 'Missing transactionIds',
      details: ['transactionIds must include at least one transaction']
    });
  }

  try {
    const user = await getOrCreateUser(deviceId);
    const newTransactions = await getUnprocessedTransactions(transactionIds);

    if (newTransactions.length === 0) {
      return res.json({
        generationsRemaining: user.generations_remaining,
        totalGenerated: user.total_generated,
        creditedTransactions: 0,
        creditedAmount: 0
      });
    }

    const creditedAmount = creditPerTransaction * newTransactions.length;
    const newGenerationsRemaining = user.generations_remaining + creditedAmount;

    await updateUserGenerations(deviceId, newGenerationsRemaining, user.total_generated);
    await recordProcessedTransactions(deviceId, productId, newTransactions);

    res.json({
      generationsRemaining: newGenerationsRemaining,
      totalGenerated: user.total_generated,
      creditedTransactions: newTransactions.length,
      creditedAmount
    });
  } catch (error) {
    console.error('❌ Failed to credit generations:', error);
    res.status(500).json({
      error: 'Failed to credit generations',
      message: error.message
    });
  }
});

export default router;

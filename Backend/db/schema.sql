-- HomeDesign AI Database Schema
-- Run this file to create the necessary tables for user and referral tracking

-- Users table: tracks generation limits and usage per device
CREATE TABLE IF NOT EXISTS users (
  device_id VARCHAR(255) PRIMARY KEY,
  generations_remaining INTEGER NOT NULL DEFAULT 3,
  total_generated INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Referrals table: tracks referral codes and their owners
CREATE TABLE IF NOT EXISTS referrals (
  code VARCHAR(10) PRIMARY KEY,
  device_id VARCHAR(255) NOT NULL,
  total_claims INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (device_id) REFERENCES users(device_id) ON DELETE CASCADE
);

-- Claims table: tracks who claimed which referral codes
CREATE TABLE IF NOT EXISTS claims (
  id SERIAL PRIMARY KEY,
  code VARCHAR(10) NOT NULL,
  claimer_device_id VARCHAR(255) NOT NULL,
  claimed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (code) REFERENCES referrals(code) ON DELETE CASCADE,
  FOREIGN KEY (claimer_device_id) REFERENCES users(device_id) ON DELETE CASCADE,
  UNIQUE(code, claimer_device_id) -- Prevent claiming same code twice
);

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_referrals_device ON referrals(device_id);
CREATE INDEX IF NOT EXISTS idx_claims_code ON claims(code);
CREATE INDEX IF NOT EXISTS idx_claims_claimer ON claims(claimer_device_id);

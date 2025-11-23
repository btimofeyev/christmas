//
//  ReferralModels.swift
//  HomeDesignAI
//
//  Models for referral system API responses
//

import Foundation

// MARK: - Referral Code Generation Response

struct ReferralCodeResponse: Codable {
    let code: String
    let shareUrl: String
    let message: String
}

// MARK: - Referral Claim Response

struct ReferralClaimResponse: Codable {
    let success: Bool
    let message: String
    let reward: ReferralReward
    let referrerDeviceId: String
}

struct ReferralReward: Codable {
    let claimer: Int    // Generations awarded to new user
    let referrer: Int   // Generations awarded to referrer
}

// MARK: - User Data Response

struct UserDataResponse: Codable {
    let generationsRemaining: Int
    let totalGenerated: Int
    let deviceId: String
}

struct CreditGenerationsResponse: Codable {
    let generationsRemaining: Int
    let totalGenerated: Int
    let creditedTransactions: Int
    let creditedAmount: Int
}

//
//  Constants.swift
//  HomeDesignAI
//
//  App-wide constants and design tokens
//

import SwiftUI

// MARK: - Design System

enum AppColors {
    // Festive palette with clean contrasts
    static let background = Color(red: 0.96, green: 0.97, blue: 0.93) // Snowy parchment
    static let surface = Color.white.opacity(0.92)
    static let text = Color(red: 0.11, green: 0.12, blue: 0.14)
    static let primary = Color(red: 0.07, green: 0.34, blue: 0.24) // Evergreen
    static let secondary = Color(red: 0.74, green: 0.05, blue: 0.17) // Cranberry
    static let accent = Color(red: 0.92, green: 0.76, blue: 0.24) // Brushed gold
    static let cardBackground = Color.white.opacity(0.95)
    static let border = Color.black.opacity(0.08)

    // Support colors
    static let snow = Color.white.opacity(0.2)
    static let deepShadow = Color.black.opacity(0.35)

    // Legacy compatibility
    static let secondaryAccent = accent
    static let subtleRed = secondary
    static let subtleGreen = primary
    static let warmNeutral = background
    static let goldAccent = accent
}

enum AppFonts {
    static let largeTitle = Font.system(.largeTitle, design: .default, weight: .bold)
    static let title = Font.system(.title, design: .default, weight: .semibold)
    static let title2 = Font.system(.title2, design: .default, weight: .semibold)
    static let title3 = Font.system(.title3, design: .default, weight: .medium)
    static let headline = Font.system(.headline, design: .default, weight: .semibold)
    static let body = Font.system(.body, design: .default, weight: .regular)
    static let callout = Font.system(.callout, design: .default, weight: .regular)
    static let caption = Font.system(.caption, design: .default, weight: .regular)
}

enum AppGradients {
    static let festive = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.82, green: 0.1, blue: 0.21),
            Color(red: 0.56, green: 0.02, blue: 0.12)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let twilight = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.7, green: 0.07, blue: 0.18),
            Color(red: 0.42, green: 0.01, blue: 0.11)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
}

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum AppCornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}

// MARK: - App Configuration

enum AppConfig {
    static let appName = "HomeDesign AI"
    static let tagline = "Transform your home for the holidays"
    static let holidayEdition = "Holiday Edition"

    // Image constraints
    static let maxImageDimension: CGFloat = 2048
    static let maxImageSizeMB: Double = 5.0

    // Timeouts
    static let apiTimeout: TimeInterval = 120 // 2 minutes for AI generation

    // Generation limits and rewards
    static let initialFreeGenerations = 3
    static let referralRewardAmount = 3 // Both referrer and referee get this amount
    static let videoShareRewardAmount = 10
    static let subscriptionBonusGenerations = 10

    // Referral system
    static let referralBaseUrl = "https://holidayhomeai.up.railway.app/r/"
    static let appStoreUrl = "https://apps.apple.com/us/app/holidayhomeai/id6755014951" // Updated with real App Store URL
    static let storyShareUrl = "https://holidayhomeai.up.railway.app"

    // RevenueCat configuration
    static let revenueCatAPIKey = "appl_ufswMSjauCXzGpJpwUkAMCkiIDK"
    static let revenueCatEntitlementId = "JMM Production Pro"
    static let revenueCatOfferingIdentifier = "default"
    static let revenueCatBasicPackProduct = "holiday_basic_pack"
    static let revenueCatHolidayUnlimitedProduct = "holiday_unlimited_pass"
}

// MARK: - Animation (2025 Apple Design - Spring Physics)

enum AppAnimation {
    // Spring-based animations (Apple 2025 standard)
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.6)
    static let springBouncy = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let springSmooth = Animation.spring(response: 0.3, dampingFraction: 0.8)

    // Legacy support
    static let standard = spring
    static let quick = Animation.spring(response: 0.25, dampingFraction: 0.7)
    static let slow = Animation.spring(response: 0.6, dampingFraction: 0.65)

    // Micro-interactions
    static let buttonPress = Animation.spring(response: 0.2, dampingFraction: 0.8)
    static let cardSelect = Animation.spring(response: 0.35, dampingFraction: 0.7)
}

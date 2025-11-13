//
//  ReviewRequestManager.swift
//  HomeDesignAI
//
//  Manages App Store review requests with intelligent timing
//

import Foundation
import StoreKit

enum ReviewTriggerEvent {
    case successfulGeneration
    case referralClaimed
    case manualReferralEntry

    var analyticsName: String {
        switch self {
        case .successfulGeneration:
            return "successful_generation"
        case .referralClaimed:
            return "referral_claimed"
        case .manualReferralEntry:
            return "manual_referral_entry"
        }
    }
}

class ReviewRequestManager {
    static let shared = ReviewRequestManager()

    // UserDefaults keys
    private let lastReviewRequestDateKey = "last_review_request_date"
    private let reviewRequestCountKey = "review_request_count"
    private let appLaunchCountKey = "app_launch_count"
    private let firstLaunchDateKey = "first_launch_date"
    private let hasRequestedForReferralKey = "has_requested_for_referral"

    // Business logic constants
    private let minimumDaysSinceFirstLaunch = 3.0
    private let minimumDaysBetweenRequests = 90.0
    private let maximumTotalRequests = 3
    private let generationMilestonesForReview = [3, 5]

    private init() {
        trackAppLaunch()
    }

    // MARK: - Public API

    /// Request a review if conditions are met
    func requestReviewIfAppropriate(event: ReviewTriggerEvent, generationCount: Int = 0) {
        guard canShowReviewPrompt(event: event, generationCount: generationCount) else {
            AnalyticsService.shared.track(event: .reviewPromptBlocked(
                trigger: event.analyticsName,
                reason: getBlockReason(event: event, generationCount: generationCount)
            ))
            return
        }

        AnalyticsService.shared.track(event: .reviewPromptEligible(
            trigger: event.analyticsName,
            generationCount: generationCount
        ))

        // Request review using StoreKit
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {

            SKStoreReviewController.requestReview(in: windowScene)

            // Track the request
            recordReviewRequest(event: event)

            AnalyticsService.shared.track(event: .reviewPromptShown(
                trigger: event.analyticsName
            ))
        }
    }

    // MARK: - Private Methods

    /// Track app launches for review eligibility
    private func trackAppLaunch() {
        let defaults = UserDefaults.standard

        // Track first launch date
        if defaults.object(forKey: firstLaunchDateKey) == nil {
            defaults.set(Date(), forKey: firstLaunchDateKey)
        }

        // Increment launch count
        let currentCount = defaults.integer(forKey: appLaunchCountKey)
        defaults.set(currentCount + 1, forKey: appLaunchCountKey)
    }

    /// Determine if we can show a review prompt
    private func canShowReviewPrompt(event: ReviewTriggerEvent, generationCount: Int) -> Bool {
        let defaults = UserDefaults.standard

        // Rule 1: Check if app is old enough (3 days since first launch)
        guard let firstLaunch = defaults.object(forKey: firstLaunchDateKey) as? Date else {
            return false
        }

        let daysSinceFirstLaunch = Date().timeIntervalSince(firstLaunch) / 86400
        guard daysSinceFirstLaunch >= minimumDaysSinceFirstLaunch else {
            return false
        }

        // Rule 2: Check if we've asked too recently (90 days)
        if let lastRequestDate = defaults.object(forKey: lastReviewRequestDateKey) as? Date {
            let daysSinceLastRequest = Date().timeIntervalSince(lastRequestDate) / 86400
            guard daysSinceLastRequest >= minimumDaysBetweenRequests else {
                return false
            }
        }

        // Rule 3: Check total request count (max 3)
        let totalRequests = defaults.integer(forKey: reviewRequestCountKey)
        guard totalRequests < maximumTotalRequests else {
            return false
        }

        // Rule 4: Event-specific conditions
        switch event {
        case .successfulGeneration:
            // Only ask at specific generation milestones (3rd, 5th)
            return generationMilestonesForReview.contains(generationCount)

        case .referralClaimed, .manualReferralEntry:
            // Only ask once for referral-related events
            let hasAskedForReferral = defaults.bool(forKey: hasRequestedForReferralKey)
            return !hasAskedForReferral
        }
    }

    /// Get the reason why a review prompt was blocked (for analytics)
    private func getBlockReason(event: ReviewTriggerEvent, generationCount: Int) -> String {
        let defaults = UserDefaults.standard

        // Check each rule in order
        guard let firstLaunch = defaults.object(forKey: firstLaunchDateKey) as? Date else {
            return "no_first_launch_date"
        }

        let daysSinceFirstLaunch = Date().timeIntervalSince(firstLaunch) / 86400
        if daysSinceFirstLaunch < minimumDaysSinceFirstLaunch {
            return "too_soon_since_install"
        }

        if let lastRequestDate = defaults.object(forKey: lastReviewRequestDateKey) as? Date {
            let daysSinceLastRequest = Date().timeIntervalSince(lastRequestDate) / 86400
            if daysSinceLastRequest < minimumDaysBetweenRequests {
                return "too_soon_since_last_request"
            }
        }

        let totalRequests = defaults.integer(forKey: reviewRequestCountKey)
        if totalRequests >= maximumTotalRequests {
            return "max_requests_reached"
        }

        switch event {
        case .successfulGeneration:
            if !generationMilestonesForReview.contains(generationCount) {
                return "not_at_milestone"
            }

        case .referralClaimed, .manualReferralEntry:
            if defaults.bool(forKey: hasRequestedForReferralKey) {
                return "already_requested_for_referral"
            }
        }

        return "unknown"
    }

    /// Record that a review was requested
    private func recordReviewRequest(event: ReviewTriggerEvent) {
        let defaults = UserDefaults.standard

        // Update last request date
        defaults.set(Date(), forKey: lastReviewRequestDateKey)

        // Increment total request count
        let currentCount = defaults.integer(forKey: reviewRequestCountKey)
        defaults.set(currentCount + 1, forKey: reviewRequestCountKey)

        // Mark referral events as used
        if case .referralClaimed = event {
            defaults.set(true, forKey: hasRequestedForReferralKey)
        } else if case .manualReferralEntry = event {
            defaults.set(true, forKey: hasRequestedForReferralKey)
        }
    }
}

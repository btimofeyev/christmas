//
//  AnalyticsService.swift
//  HomeDesignAI
//
//  Analytics tracking (placeholder implementation)
//  TODO: Integrate Firebase or PostHog when ready
//

import Foundation

// MARK: - Analytics Events

enum AnalyticsEvent {
    case appLaunched
    case uploadPhotoTapped
    case photoSelected
    case sceneSelected(SceneType)
    case styleSelected(DecorStyle)
    case customPromptEntered
    case generateStarted
    case generateCompleted(success: Bool, duration: TimeInterval)
    case productClicked(productName: String, style: String, price: String, position: Int)
    case imageSaved
    case imageShared
    case referralCodeGenerated
    case sharedToUnlock
    case referralClaimed(code: String)
    case noGenerationsRemaining
    case videoCreated
    case videoShared
    case errorOccurred(error: String)

    var name: String {
        switch self {
        case .appLaunched: return "app_launched"
        case .uploadPhotoTapped: return "upload_photo_tapped"
        case .photoSelected: return "photo_selected"
        case .sceneSelected: return "scene_selected"
        case .styleSelected: return "style_selected"
        case .customPromptEntered: return "custom_prompt_entered"
        case .generateStarted: return "generate_started"
        case .generateCompleted: return "generate_completed"
        case .productClicked: return "product_clicked"
        case .imageSaved: return "image_saved"
        case .imageShared: return "image_shared"
        case .referralCodeGenerated: return "referral_code_generated"
        case .sharedToUnlock: return "shared_to_unlock"
        case .referralClaimed: return "referral_claimed"
        case .noGenerationsRemaining: return "no_generations_remaining"
        case .videoCreated: return "video_created"
        case .videoShared: return "video_shared"
        case .errorOccurred: return "error_occurred"
        }
    }

    var parameters: [String: Any] {
        switch self {
        case .sceneSelected(let scene):
            return ["scene_type": scene.rawValue]
        case .styleSelected(let style):
            return ["style": style.rawValue]
        case .generateCompleted(let success, let duration):
            return ["success": success, "duration_seconds": duration]
        case .productClicked(let productName, let style, let price, let position):
            return [
                "product_name": productName,
                "style": style,
                "product_price": price,
                "product_position": position
            ]
        case .errorOccurred(let error):
            return ["error_message": error]
        case .referralClaimed(let code):
            return ["referral_code": code]
        default:
            return [:]
        }
    }
}

// MARK: - Analytics Protocol

protocol AnalyticsTracking {
    func track(event: AnalyticsEvent)
    func setUserProperty(key: String, value: String)
}

// MARK: - Analytics Service

class AnalyticsService: AnalyticsTracking {
    static let shared = AnalyticsService()

    private init() {}

    // MARK: - Tracking

    func track(event: AnalyticsEvent) {
        #if DEBUG
        print("📊 Analytics: \(event.name)")
        if !event.parameters.isEmpty {
            print("   Parameters: \(event.parameters)")
        }
        #endif

        // TODO: Implement actual analytics tracking
        // Example for Firebase:
        // Analytics.logEvent(event.name, parameters: event.parameters)

        // Example for PostHog:
        // PostHogSDK.shared.capture(event.name, properties: event.parameters)
    }

    func setUserProperty(key: String, value: String) {
        #if DEBUG
        print("📊 Analytics: Set property \(key) = \(value)")
        #endif

        // TODO: Implement user property tracking
        // Example for Firebase:
        // Analytics.setUserProperty(value, forName: key)

        // Example for PostHog:
        // PostHogSDK.shared.identify(distinctId: userId, userProperties: [key: value])
    }

    // MARK: - Convenience Methods

    func trackScreen(_ screenName: String) {
        #if DEBUG
        print("📊 Analytics: Screen view - \(screenName)")
        #endif

        // TODO: Implement screen tracking
    }
}

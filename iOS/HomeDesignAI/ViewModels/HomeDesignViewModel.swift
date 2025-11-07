//
//  HomeDesignViewModel.swift
//  HomeDesignAI
//
//  Main ViewModel managing app state and business logic (MVVM)
//

import Foundation
import SwiftUI
import AVFoundation

@MainActor
class HomeDesignViewModel: ObservableObject {

    // MARK: - Published State

    // Navigation
    @Published var currentStep: AppStep = .welcome

    // Image Selection
    @Published var selectedImage: UIImage?
    @Published var showImagePicker = false
    @Published var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary

    // Scene & Style Selection
    @Published var selectedScene: SceneType = .interior
    @Published var selectedStyle: DecorStyle?
    @Published var customPrompt: String = ""
    @Published var lightingMode: LightingMode = .day
    @Published var decorationIntensity: DecorationIntensity = .medium

    // Generation State
    @Published var isGenerating = false
    @Published var generationProgress: Double = 0.0
    @Published var generationStartTime: Date?

    // Results
    @Published var decoratedImage: UIImage?
    @Published var products: [AffiliateProduct] = []

    // Error Handling
    @Published var showError = false
    @Published var errorMessage: String = ""

    // Referral System
    @Published var showReferralPrompt = false
    @Published var myReferralCode: String?
    @Published var myReferralUrl: String?
    @Published var isGeneratingReferralCode = false
    @Published var referralRewardMessage: String = ""
    @Published var showReferralReward = false

    // Generation Limits
    @Published var generationsRemaining: Int = AppConfig.initialFreeGenerations
    private let generationsKey = "user_generations_remaining"
    private let myReferralCodeKey = "my_referral_code"
    private let myReferralUrlKey = "my_referral_url"
    private let claimedReferralCodesKey = "claimed_referral_codes"

    // Video Export
    @Published var isCreatingVideo = false
    @Published var videoURL: URL?
    @Published var showVideoShare = false

    // MARK: - Services

    private let apiService = APIService.shared
    private let analytics = AnalyticsService.shared
    // Note: Uncomment these after adding EmailService.swift and VideoExporter.swift to Xcode project
    // private let emailService = EmailService.shared
    // private let videoExporter = VideoExporter.shared

    // MARK: - App Steps

    enum AppStep {
        case welcome
        case uploadPhoto
        case sceneSelection
        case styleSelection
        case generating
        case result
    }

    // MARK: - Lighting Mode

    enum LightingMode: String, CaseIterable {
        case day
        case night

        var displayName: String {
            switch self {
            case .day:
                return "Day"
            case .night:
                return "Night"
            }
        }

        var icon: String {
            switch self {
            case .day:
                return "sun.max.fill"
            case .night:
                return "moon.stars.fill"
            }
        }

        var description: String {
            switch self {
            case .day:
                return "Natural daylight ambiance"
            case .night:
                return "Evening lights and glow"
            }
        }
    }

    // MARK: - Initialization

    init() {
        analytics.track(event: .appLaunched)

        // Load referral code if exists
        myReferralCode = UserDefaults.standard.string(forKey: myReferralCodeKey)
        myReferralUrl = UserDefaults.standard.string(forKey: myReferralUrlKey)

        // Load generation count from storage
        let storedGenerations = UserDefaults.standard.integer(forKey: generationsKey)
        if storedGenerations == 0 {
            // First time user - give initial free generations
            generationsRemaining = AppConfig.initialFreeGenerations
            saveGenerationCount()
        } else {
            generationsRemaining = storedGenerations
        }
    }

    // MARK: - Navigation

    func goToStep(_ step: AppStep) {
        withAnimation(AppAnimation.standard) {
            currentStep = step
        }
    }

    func reset() {
        withAnimation(AppAnimation.standard) {
            currentStep = .uploadPhoto  // Start at upload, not welcome
            selectedImage = nil
            selectedScene = .interior
            selectedStyle = nil
            customPrompt = ""
            lightingMode = .day
            decorationIntensity = .medium
            decoratedImage = nil
            products = []
            isGenerating = false
            generationProgress = 0.0
            showError = false
            errorMessage = ""
        }
    }

    // MARK: - Image Selection

    func selectImageSource(_ sourceType: UIImagePickerController.SourceType) {
        imagePickerSourceType = sourceType
        showImagePicker = true
        analytics.track(event: .uploadPhotoTapped)
    }

    func imageSelected(_ image: UIImage) {
        selectedImage = image
        showImagePicker = false
        analytics.track(event: .photoSelected)

        // Haptic feedback for successful photo selection
        HapticFeedback.success()

        // Automatically move to scene selection
        goToStep(.sceneSelection)
    }

    // MARK: - Scene Selection

    func selectScene(_ scene: SceneType) {
        selectedScene = scene
        analytics.track(event: .sceneSelected(scene))

        // Haptic feedback for selection
        HapticFeedback.selection()

        // Don't automatically move - let user choose lighting and click Continue
    }

    // MARK: - Style Selection

    func selectStyle(_ style: DecorStyle) {
        selectedStyle = style
        analytics.track(event: .styleSelected(style))

        // Haptic feedback for selection
        HapticFeedback.selection()

        // If custom style, don't auto-generate (wait for prompt)
        if style != .custom {
            startGeneration()
        }
    }

    func selectCustomStyle(prompt: String) {
        guard prompt.isNotEmpty else {
            showErrorMessage("Please enter a description for your custom style")
            return
        }

        selectedStyle = .custom
        customPrompt = prompt
        analytics.track(event: .customPromptEntered)
        startGeneration()
    }

    // MARK: - Generation

    func startGeneration() {
        guard let image = selectedImage,
              let style = selectedStyle else {
            showErrorMessage("Missing required information")
            return
        }

        // Check if user has generations remaining
        if generationsRemaining <= 0 {
            // Show referral prompt to earn more generations
            showReferralPrompt = true
            return
        }

        // Optimistically decrement generation count (restore if API fails)
        generationsRemaining -= 1
        saveGenerationCount()

        Task {
            isGenerating = true
            generationProgress = 0.0
            generationStartTime = Date()
            goToStep(.generating)

            analytics.track(event: .generateStarted)

            // Simulate progress (since we don't get real progress from API)
            startProgressSimulation()

            do {
                let response = try await apiService.generateDecoratedImage(
                    image: image,
                    scene: selectedScene,
                    style: style,
                    customPrompt: customPrompt.isNotEmpty ? customPrompt : nil,
                    lighting: lightingMode,
                    intensity: decorationIntensity
                )

                // Process response
                if let decoratedUIImage = ImageProcessor.shared.convertFromBase64(response.decoratedImageBase64) {
                    decoratedImage = decoratedUIImage
                    products = response.products

                    // Generation count already decremented optimistically at start

                    // Track success
                    let duration = Date().timeIntervalSince(generationStartTime ?? Date())
                    analytics.track(event: .generateCompleted(success: true, duration: duration))

                    // Haptic feedback for successful generation
                    HapticFeedback.success()

                    // Show result
                    isGenerating = false
                    generationProgress = 1.0
                    goToStep(.result)
                } else {
                    throw APIError.invalidResponse
                }

            } catch {
                // Track failure
                let duration = Date().timeIntervalSince(generationStartTime ?? Date())
                analytics.track(event: .generateCompleted(success: false, duration: duration))
                analytics.track(event: .errorOccurred(error: error.localizedDescription))

                // Restore generation count since API failed
                generationsRemaining += 1
                saveGenerationCount()

                // Haptic feedback for error
                HapticFeedback.error()

                isGenerating = false
                showErrorMessage(error.localizedDescription)
                goToStep(.styleSelection) // Go back to style selection
            }
        }
    }

    /// Simulates progress for better UX (since API doesn't provide real progress)
    private func startProgressSimulation() {
        Task {
            // Simulate progress in stages
            for i in 1...20 {
                if !isGenerating { break }

                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                generationProgress = Double(i) * 0.045 // Up to 90%
            }
        }
    }

    // MARK: - Product Actions

    func productTapped(_ product: AffiliateProduct, at position: Int = 0) {
        // Track with detailed analytics
        analytics.track(event: .productClicked(
            productName: product.name,
            style: selectedStyle?.rawValue ?? "unknown",
            price: product.price,
            position: position
        ))

        // Open affiliate link in Safari (modern API)
        guard let url = URL(string: product.link) else {
            #if DEBUG
            print("❌ Invalid product URL: \(product.link)")
            #endif
            showErrorMessage("Unable to open product link. Please try again.")
            return
        }

        // Validate URL scheme
        guard url.scheme == "http" || url.scheme == "https" else {
            #if DEBUG
            print("❌ Invalid URL scheme: \(url.scheme ?? "none")")
            #endif
            showErrorMessage("Invalid product link format.")
            return
        }

        #if DEBUG
        print("🔗 Opening product link: \(url.absoluteString)")
        #endif

        UIApplication.shared.open(url, options: [:]) { [weak self] success in
            #if DEBUG
            if success {
                print("✅ Opened affiliate link: \(product.name) at position \(position)")
            } else {
                print("❌ Failed to open affiliate link: \(product.name)")
            }
            #endif
            if !success {
                // Note: On iOS Simulator, Safari may not have internet connectivity
                // This will work properly on a real device
                DispatchQueue.main.async {
                    self?.showErrorMessage("Unable to open product link. If you're using the simulator, please test on a real device.")
                }
            }
        }
    }

    // MARK: - Image Actions

    func saveImage() {
        guard let image = decoratedImage else { return }

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        analytics.track(event: .imageSaved)

        // Haptic feedback for successful save
        HapticFeedback.success()
    }

    func shareImage() -> some View {
        guard let image = decoratedImage else {
            return AnyView(EmptyView())
        }

        analytics.track(event: .imageShared)

        return AnyView(
            ShareSheet(items: [image])
        )
    }

    private func saveGenerationCount() {
        UserDefaults.standard.set(generationsRemaining, forKey: generationsKey)
    }

    // MARK: - Video Export

    func trackVideoShared() {
        analytics.track(event: .videoShared)
    }

    func createAndShareVideo() {
        // TODO: Add VideoExporter.swift to Xcode project first, then uncomment
        showErrorMessage("Video export requires adding VideoExporter.swift to Xcode project")
        /*
        guard let beforeImage = selectedImage,
              let afterImage = decoratedImage else {
            showErrorMessage("Missing images for video creation")
            return
        }

        isCreatingVideo = true

        videoExporter.createBeforeAfterVideo(beforeImage: beforeImage, afterImage: afterImage) { [weak self] (result: Result<URL, VideoExportError>) in
            guard let self = self else { return }

            self.isCreatingVideo = false

            switch result {
            case .success(let url):
                self.videoURL = url
                self.showVideoShare = true

                // Track success
                self.analytics.track(event: .videoCreated)

                // Haptic feedback
                HapticFeedback.success()

            case .failure(let error):
                self.showErrorMessage(error.localizedDescription)

                // Track error
                self.analytics.track(event: .errorOccurred(error: error.localizedDescription))

                // Haptic feedback
                HapticFeedback.error()
            }
        }
        */
    }

    // MARK: - Referral System

    /// Get device identifier for referral tracking
    private var deviceId: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }

    /// Generate or retrieve user's referral code
    func generateOrGetReferralCode() {
        // Return existing code if available
        if let existingCode = myReferralCode, let existingUrl = myReferralUrl {
            return
        }

        Task {
            isGeneratingReferralCode = true

            do {
                let response = try await apiService.generateReferralCode(deviceId: deviceId)

                // Store referral code
                self.myReferralCode = response.code
                self.myReferralUrl = response.shareUrl
                UserDefaults.standard.set(response.code, forKey: myReferralCodeKey)
                UserDefaults.standard.set(response.shareUrl, forKey: myReferralUrlKey)

                // Track event
                analytics.track(event: .referralCodeGenerated)

            } catch {
                #if DEBUG
                print("Failed to generate referral code: \(error)")
                #endif
                // Fail silently - user can try again
            }

            isGeneratingReferralCode = false
        }
    }

    /// Claim a referral code (called when user opens app via referral link)
    func claimReferral(code: String) {
        // Check if already claimed this code
        let claimedCodes = UserDefaults.standard.stringArray(forKey: claimedReferralCodesKey) ?? []
        if claimedCodes.contains(code) {
            // Already claimed, ignore
            return
        }

        Task {
            do {
                let response = try await apiService.claimReferral(code: code, deviceId: deviceId)

                // Award generations to current user
                self.generationsRemaining += response.reward.claimer
                saveGenerationCount()

                // Mark code as claimed
                var updatedClaimedCodes = claimedCodes
                updatedClaimedCodes.append(code)
                UserDefaults.standard.set(updatedClaimedCodes, forKey: claimedReferralCodesKey)

                // Show success message
                self.referralRewardMessage = "Welcome! You earned \(response.reward.claimer) free designs! 🎁"
                self.showReferralReward = true

                // Track event
                analytics.track(event: .referralClaimed(code: code))

                // Haptic feedback
                HapticFeedback.success()

                // Auto-dismiss after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showReferralReward = false
                }

            } catch {
                #if DEBUG
                print("Failed to claim referral: \(error)")
                #endif
                // Fail silently - might be invalid/expired code
            }
        }
    }

    /// Share referral link to invite friends
    func shareReferralLink() -> some View {
        // Generate code if doesn't exist
        if myReferralCode == nil {
            generateOrGetReferralCode()
        }

        guard let referralUrl = myReferralUrl else {
            return AnyView(EmptyView())
        }

        let shareText = "Transform your space for the holidays with AI! 🎄✨\nGet HolidayHome AI free and we both earn +\(AppConfig.referralRewardAmount) designs:\n\(referralUrl)"

        analytics.track(event: .sharedToUnlock)

        return AnyView(
            ShareSheet(items: [shareText])
        )
    }

    // MARK: - Error Handling

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

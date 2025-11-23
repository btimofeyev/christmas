//
//  HomeDesignViewModel.swift
//  HomeDesignAI
//
//  Main ViewModel managing app state and business logic (MVVM)
//

import Foundation
import SwiftUI
import AVFoundation
import RevenueCat

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
    @Published var rewardTitle: String = "Reward Unlocked"
    @Published var showReferralReward = false
    @Published var hasProSubscription = false

    // Manual Referral Code Entry
    @Published var showReferralCodeEntry = false
    @Published var referralCodeInput: String = ""
    @Published var isClaimingReferral = false

    // Generation Limits
    @Published var generationsRemaining: Int = AppConfig.initialFreeGenerations
    @Published var totalDesignsGenerated: Int = 0
    private let generationsKey = "user_generations_remaining"
    private let totalGeneratedKey = "total_designs_generated"
    private let myReferralCodeKey = "my_referral_code"
    private let myReferralUrlKey = "my_referral_url"
    private let claimedReferralCodesKey = "claimed_referral_codes"
    private let videoShareRewardKey = "video_share_reward_awarded"
    private let subscriptionRewardDateKey = "subscription_reward_date"
    private let processedBasicPackTransactionsKey = "processed_basic_pack_transactions"

    private var hasEarnedVideoShareReward: Bool {
        get { UserDefaults.standard.bool(forKey: videoShareRewardKey) }
        set { UserDefaults.standard.set(newValue, forKey: videoShareRewardKey) }
    }

    private var lastSubscriptionRewardTimestamp: TimeInterval {
        get { UserDefaults.standard.double(forKey: subscriptionRewardDateKey) }
        set { UserDefaults.standard.set(newValue, forKey: subscriptionRewardDateKey) }
    }

    private var processedBasicPackTransactions: Set<String> {
        get { Set(UserDefaults.standard.stringArray(forKey: processedBasicPackTransactionsKey) ?? []) }
        set { UserDefaults.standard.set(Array(newValue), forKey: processedBasicPackTransactionsKey) }
    }

    // Video Export
    @Published var isCreatingVideo = false
    @Published var videoURL: URL?
    @Published var showVideoPreview = false

    // MARK: - Services

    private let apiService = APIService.shared
    private let analytics = AnalyticsService.shared
    // private let emailService = EmailService.shared
    private let videoExporter = VideoExporter.shared

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

        // Migration: Clear old referral URLs that don't match current domain
        if let existingUrl = myReferralUrl,
           !existingUrl.contains("holidayhomeai.up.railway.app") {
            // Clear old cached URL - will be regenerated with correct domain
            myReferralUrl = nil
            myReferralCode = nil
            UserDefaults.standard.removeObject(forKey: myReferralCodeKey)
            UserDefaults.standard.removeObject(forKey: myReferralUrlKey)
        }

        // Load generation count from storage
        let storedGenerations = UserDefaults.standard.integer(forKey: generationsKey)
        if storedGenerations == 0 {
            // First time user - give initial free generations
            generationsRemaining = AppConfig.initialFreeGenerations
            saveGenerationCount()
        } else {
            generationsRemaining = storedGenerations
        }

        // Load total designs generated
        totalDesignsGenerated = UserDefaults.standard.integer(forKey: totalGeneratedKey)

        // Sync counts from backend on launch (backend is source of truth)
        syncGenerationCountsFromBackend()
    }

    // MARK: - Backend Sync

    /// Syncs generation counts from backend on app launch
    private func syncGenerationCountsFromBackend() {
        Task {
            do {
                // Get or create user to sync counts
                let user = try await apiService.getOrCreateUser(deviceId: deviceId)

                // Update local state with backend counts
                self.generationsRemaining = user.generationsRemaining
                self.totalDesignsGenerated = user.totalGenerated
                saveGenerationCount()
                UserDefaults.standard.set(user.totalGenerated, forKey: totalGeneratedKey)

                #if DEBUG
                print("✅ Synced generation counts from backend: \(user.generationsRemaining) remaining, \(user.totalGenerated) total")
                #endif
            } catch {
                #if DEBUG
                print("⚠️ Failed to sync generation counts from backend: \(error.localizedDescription)")
                #endif
                // Fail silently - use local counts as fallback
            }
        }
    }

    // MARK: - Navigation

    func goToStep(_ step: AppStep) {
        withAnimation(AppAnimation.standard) {
            currentStep = step
        }
    }

    func reset() {
        // Check if user has generations remaining before allowing new design
        if generationsRemaining <= 0 {
            // Show referral prompt to earn more generations
            showReferralPrompt = true
            analytics.track(event: .noGenerationsRemaining)

            // Haptic feedback to indicate limit reached
            HapticFeedback.error()
            return
        }

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
            isCreatingVideo = false
            videoURL = nil
            showVideoPreview = false
            errorMessage = ""
        }
    }

    // MARK: - Image Selection

    func selectImageSource(_ sourceType: UIImagePickerController.SourceType) {
        // Check if user has generations remaining before allowing upload
        if generationsRemaining <= 0 {
            // Show referral prompt to earn more generations
            showReferralPrompt = true
            analytics.track(event: .noGenerationsRemaining)

            // Haptic feedback to indicate limit reached
            HapticFeedback.error()
            return
        }

        imagePickerSourceType = sourceType
        showImagePicker = true
        analytics.track(event: .uploadPhotoTapped)
    }

    func imageSelected(_ image: UIImage) {
        selectedImage = image
        showImagePicker = false
        analytics.track(event: .photoSelected)

        // Check if user has generations remaining (in case it changed since picker opened)
        if generationsRemaining <= 0 {
            // Show referral prompt to earn more generations
            showReferralPrompt = true
            analytics.track(event: .noGenerationsRemaining)

            // Haptic feedback to indicate limit reached
            HapticFeedback.error()
            return
        }

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

                    // Sync generation count from backend (backend is source of truth)
                    if let remaining = response.generationsRemaining {
                        generationsRemaining = remaining
                        saveGenerationCount()
                    }

                    // Sync total designs generated from backend
                    if let total = response.totalGenerated {
                        totalDesignsGenerated = total
                        UserDefaults.standard.set(total, forKey: totalGeneratedKey)
                    }

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

                // Check if error contains updated generation counts from backend
                if let apiError = error as? APIError {
                    // Sync from backend if available (backend is source of truth)
                    if let remaining = apiError.generationsRemaining {
                        generationsRemaining = remaining
                        saveGenerationCount()
                    } else {
                        // No backend count, restore the optimistically decremented count
                        generationsRemaining += 1
                        saveGenerationCount()
                    }

                    if let total = apiError.totalGenerated {
                        totalDesignsGenerated = total
                        UserDefaults.standard.set(total, forKey: totalGeneratedKey)
                    }
                } else {
                    // Unknown error type, restore count
                    generationsRemaining += 1
                    saveGenerationCount()
                }

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

    func handleVideoStoryShareTapped() {
        trackVideoShared()
        grantVideoShareBonusIfNeeded()
    }

    func createAndShareVideo() {
        guard !isCreatingVideo else { return }

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
                self.showVideoPreview = true

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
    }

    func cleanupVideoShare() {
        if let url = videoURL {
            try? FileManager.default.removeItem(at: url)
        }
        videoURL = nil
        showVideoPreview = false
    }

    private func grantVideoShareBonusIfNeeded() {
        guard !hasEarnedVideoShareReward else { return }

        hasEarnedVideoShareReward = true
        generationsRemaining += AppConfig.videoShareRewardAmount
        saveGenerationCount()

        referralRewardMessage = "Thanks for sharing! Enjoy +\(AppConfig.videoShareRewardAmount) extra designs 🎁"
        rewardTitle = "Video Bonus"
        showReferralReward = true

        HapticFeedback.success()
    }

    // MARK: - Purchases & Subscriptions

    func handleSubscriptionUpdate(_ customerInfo: CustomerInfo?) {
        guard let info = customerInfo else {
            hasProSubscription = false
            return
        }

        let entitlement = info.entitlements[AppConfig.revenueCatEntitlementId]
        let isActive = entitlement?.isActive == true
        hasProSubscription = isActive

        if
            isActive,
            let latestPurchaseDate = entitlement?.latestPurchaseDate
        {
            let timestamp = latestPurchaseDate.timeIntervalSince1970
            if timestamp > lastSubscriptionRewardTimestamp {
                lastSubscriptionRewardTimestamp = timestamp
                applySubscriptionBonus(productId: entitlement?.productIdentifier)
            }
        }

        handleBasicPackPurchases(info)
    }

    private func applySubscriptionBonus(productId: String?) {
        generationsRemaining += AppConfig.subscriptionBonusGenerations
        saveGenerationCount()
        rewardTitle = "Premium Reward"
        referralRewardMessage = "Thanks for supporting HomeDesign AI! Enjoy +\(AppConfig.subscriptionBonusGenerations) extra designs 🎁"
        showReferralReward = true

        if let productId {
            analytics.track(event: .subscriptionUnlocked(productId: productId))
        }

        HapticFeedback.success()
    }

    private func handleBasicPackPurchases(_ info: CustomerInfo) {
        let transactions = info.nonSubscriptions.filter {
            $0.productIdentifier == AppConfig.revenueCatBasicPackProduct
        }
        guard !transactions.isEmpty else { return }

        var processed = processedBasicPackTransactions
        let newTransactionIds = transactions.compactMap { transaction -> String? in
            let identifier = transaction.transactionIdentifier
            return processed.contains(identifier) ? nil : identifier
        }

        guard !newTransactionIds.isEmpty else { return }

        newTransactionIds.forEach { processed.insert($0) }
        processedBasicPackTransactions = processed

        let generationsEarned = AppConfig.subscriptionBonusGenerations * newTransactionIds.count
        generationsRemaining += generationsEarned
        saveGenerationCount()

        rewardTitle = "Holiday Pack Added"
        referralRewardMessage = "Enjoy +\(generationsEarned) extra designs 🎁"
        showReferralReward = true
        analytics.track(event: .subscriptionUnlocked(productId: AppConfig.revenueCatBasicPackProduct))
        HapticFeedback.success()
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
                self.rewardTitle = "Referral Reward"
                self.referralRewardMessage = "Welcome! You earned \(response.reward.claimer) free designs! 🎁"
                self.showReferralReward = true

                // Track event
                analytics.track(event: .referralClaimed(code: code))

                // Haptic feedback
                HapticFeedback.success()

                // Request review after successful referral claim
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    ReviewRequestManager.shared.requestReviewIfAppropriate(event: .referralClaimed)
                }

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

    /// Manual referral code entry from present button
    func enterReferralCodeManually(code: String) {
        // Clean the input code
        let cleanCode = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        // Validate code format
        guard cleanCode.count == 6 else {
            errorMessage = "Please enter a valid 6-character referral code"
            showError = true
            return
        }

        // Check if already claimed this code
        let claimedCodes = UserDefaults.standard.stringArray(forKey: claimedReferralCodesKey) ?? []
        if claimedCodes.contains(cleanCode) {
            errorMessage = "You've already used this referral code"
            showError = true
            return
        }

        Task {
            do {
                isClaimingReferral = true

                let response = try await apiService.claimReferral(code: cleanCode, deviceId: deviceId)

                // Award generations to current user
                self.generationsRemaining += response.reward.claimer
                saveGenerationCount()

                // Mark code as claimed
                var updatedClaimedCodes = claimedCodes
                updatedClaimedCodes.append(cleanCode)
                UserDefaults.standard.set(updatedClaimedCodes, forKey: claimedReferralCodesKey)

                // Show success message
                self.rewardTitle = "Referral Reward"
                self.referralRewardMessage = "Success! You earned \(response.reward.claimer) free designs! 🎁"
                self.showReferralReward = true

                // Track event
                analytics.track(event: .referralClaimed(code: cleanCode))

                // Haptic feedback
                HapticFeedback.success()

                // Request review after successful manual referral entry
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    ReviewRequestManager.shared.requestReviewIfAppropriate(event: .manualReferralEntry)
                }

                // Reset input
                self.referralCodeInput = ""
                self.showReferralCodeEntry = false

            } catch {
                #if DEBUG
                print("Failed to claim referral: \(error)")
                #endif
                errorMessage = "Invalid or expired referral code"
                showError = true
            }

            isClaimingReferral = false
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
    var completion: ((Bool) -> Void)? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, completed, _, _ in
            guard let completion = completion else { return }
            DispatchQueue.main.async {
                completion(completed)
            }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

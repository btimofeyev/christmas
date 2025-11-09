//
//  ContentView.swift
//  HomeDesignAI
//
//  Main content view with navigation logic
//  Enhanced with 2025 Apple Design - smooth spring transitions
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HomeDesignViewModel()
    @Namespace private var heroNamespace

    var body: some View {
        ZStack {
            // Main content based on current step
            switch viewModel.currentStep {
            case .welcome:
                WelcomeView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 1.0).combined(with: .opacity),
                        removal: .scale(scale: 0.95).combined(with: .opacity)
                    ))

            case .uploadPhoto:
                UploadPhotoView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .sceneSelection:
                SceneSelectionView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .styleSelection:
                StyleSelectionView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .generating:
                GeneratingView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 1.05).combined(with: .opacity),
                        removal: .scale(scale: 0.95).combined(with: .opacity)
                    ))

            case .result:
                ResultView(viewModel: viewModel)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 1.05).combined(with: .opacity),
                        removal: .scale(scale: 0.95).combined(with: .opacity)
                    ))
            }
        }
        .animation(AppAnimation.spring, value: viewModel.currentStep)
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("Referral Reward!", isPresented: $viewModel.showReferralReward) {
            Button("Awesome!", role: .cancel) {}
        } message: {
            Text(viewModel.referralRewardMessage)
        }
        .sheet(isPresented: $viewModel.showReferralPrompt) {
            NoGenerationsView(viewModel: viewModel)
        }
        .onOpenURL { url in
            handleDeepLink(url: url)
        }
    }

    // MARK: - Deep Link Handling

    private func handleDeepLink(url: URL) {
        // Handle referral links: holidayhomeai://r/ABC123
        // Also handle https://holidayhomeai.app/r/ABC123 (if Universal Links configured)

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }

        // Check for referral path
        let path = components.path
        if path.hasPrefix("/r/") || path.hasPrefix("r/") {
            // Extract referral code
            let code = path.replacingOccurrences(of: "/r/", with: "")
                           .replacingOccurrences(of: "r/", with: "")
                           .trimmingCharacters(in: .whitespaces)

            if !code.isEmpty {
                // Claim the referral code
                viewModel.claimReferral(code: code)
            }
        }
    }
}

#Preview {
    ContentView()
}

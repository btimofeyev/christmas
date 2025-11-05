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
    }
}

#Preview {
    ContentView()
}

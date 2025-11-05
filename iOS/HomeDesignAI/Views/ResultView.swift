//
//  ResultView.swift
//  HomeDesignAI
//
//  Festive result screen with single-view layout
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var viewModel: HomeDesignViewModel
    @State private var showShareSheet = false
    @State private var showingOriginal = false
    @State private var showFullScreen = false
    @State private var celebrationParticles: [CelebrationParticle] = []
    @State private var showCelebration = false
    @State private var showEmailSheet = false
    @State private var emailInput = ""
    @State private var showAbout = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            AppGradients.festive
                .ignoresSafeArea()

            FestiveSnowfallView()

            VStack(spacing: AppSpacing.lg) {
                Spacer(minLength: AppSpacing.lg)

                VStack(spacing: AppSpacing.xs) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .scaleEffect(showCelebration ? 1.0 : 0.5)
                        .opacity(showCelebration ? 1.0 : 0.0)
                        .animation(AppAnimation.springBouncy.delay(0.2), value: showCelebration)

                    Text("Your holiday design is ready!")
                        .font(AppFonts.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .scaleEffect(showCelebration ? 1.0 : 0.85)
                        .opacity(showCelebration ? 1.0 : 0.0)
                        .animation(AppAnimation.springBouncy.delay(0.3), value: showCelebration)
                }

                if let decoratedImage = viewModel.decoratedImage,
                   let originalImage = viewModel.selectedImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: showingOriginal ? originalImage : decoratedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .frame(height: 280)
                            .cornerRadius(AppCornerRadius.lg)
                            .shadow(color: AppColors.deepShadow.opacity(0.28), radius: 18, x: 0, y: 12)
                            .opacity(showCelebration ? 1.0 : 0.0)
                            .animation(AppAnimation.springBouncy.delay(0.5), value: showCelebration)
                            .onTapGesture {
                                showFullScreen = true
                            }

                        Button(action: {
                            showingOriginal.toggle()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: showingOriginal ? "sparkles" : "photo")
                                Text(showingOriginal ? "Design" : "Original")
                                    .fontWeight(.semibold)
                            }
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(AppColors.surface)
                            .cornerRadius(20)
                            .shadow(color: AppColors.deepShadow.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .pressAnimation()
                        .padding(AppSpacing.sm)
                        .opacity(showCelebration ? 1.0 : 0.0)
                        .animation(AppAnimation.spring.delay(0.6), value: showCelebration)
                    }
                }

                HStack(spacing: AppSpacing.md) {
                    ResultActionButton(
                        icon: "square.and.arrow.down",
                        label: "Save",
                        background: AppColors.surface,
                        foreground: AppColors.primary
                    ) {
                        viewModel.saveImage()
                    }
                    .accessibilityLabel("Save image")
                    .accessibilityHint("Save decorated image to your photo library")

                    ResultActionButton(
                        icon: "square.and.arrow.up",
                        label: "Share",
                        background: AppColors.accent,
                        foreground: AppColors.primary
                    ) {
                        showShareSheet = true
                    }
                    .accessibilityLabel("Share image")
                    .accessibilityHint("Share your decorated space with others")

                    ResultActionButton(
                        icon: "arrow.counterclockwise",
                        label: "New",
                        background: AppColors.surface,
                        foreground: AppColors.primary
                    ) {
                        viewModel.reset()
                    }
                    .accessibilityLabel("Start new design")
                    .accessibilityHint("Reset and create a new decoration design")
                }
                .opacity(showCelebration ? 1.0 : 0.0)
                .animation(AppAnimation.spring.delay(0.7), value: showCelebration)

                if !viewModel.products.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Shop the look")
                            .font(AppFonts.headline)
                            .foregroundColor(.white)

                        VStack(spacing: AppSpacing.sm) {
                            ForEach(Array(viewModel.products.prefix(3).enumerated()), id: \.element.id) { index, product in
                                ProductSummaryRow(product: product) {
                                    viewModel.productTapped(product, at: index)
                                }
                            }
                        }

                        Text("As an Amazon Associate we earn from qualifying purchases.")
                            .font(AppFonts.caption)
                            .foregroundColor(Color.white.opacity(0.65))
                            .multilineTextAlignment(.leading)
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.surface.opacity(0.2))
                    .cornerRadius(AppCornerRadius.lg)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: AppColors.deepShadow.opacity(0.25), radius: 14, x: 0, y: 8)
                    .opacity(showCelebration ? 1.0 : 0.0)
                    .animation(AppAnimation.spring.delay(0.8), value: showCelebration)
                }

                Spacer()
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.bottom, AppSpacing.lg)

            // About button in top-left corner
            VStack {
                HStack {
                    Button(action: { showAbout = true }) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.9))
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.2))
                                    .frame(width: 34, height: 34)
                            )
                    }
                    .accessibilityLabel("About")
                    .accessibilityHint("View app information, privacy policy, and terms of service")
                    .padding(.top, 50)
                    .padding(.leading, 20)
                    Spacer()
                }
                Spacer()
            }

            if !reduceMotion && !celebrationParticles.isEmpty {
                ForEach(celebrationParticles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                }
                .allowsHitTesting(false)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = viewModel.decoratedImage {
                ShareSheet(items: [image])
            }
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            if let decoratedImage = viewModel.decoratedImage,
               let originalImage = viewModel.selectedImage {
                FullScreenImageView(
                    image: showingOriginal ? originalImage : decoratedImage,
                    isPresented: $showFullScreen
                )
            }
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .overlay(
            Group {
                if showEmailSheet && !viewModel.hasSubmittedEmail {
                    EmailBottomSheet(
                        isPresented: $showEmailSheet,
                        email: $emailInput,
                        isSubscribed: $viewModel.hasSubmittedEmail,
                        onSubmit: {
                            viewModel.subscribeToMainApp(email: emailInput)
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
        )
        .onAppear {
            withAnimation {
                showCelebration = true
            }

            if !reduceMotion {
                generateCelebrationParticles()
            }

            if !viewModel.hasSubmittedEmail && viewModel.generationsRemaining < 10 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.spring()) {
                        showEmailSheet = true
                    }
                }
            }
        }
    }

    private func generateCelebrationParticles() {
        let screenWidth = UIScreen.main.bounds.width
        let colors = [AppColors.accent, AppColors.surface, AppColors.secondary, AppColors.primary]

        celebrationParticles = (0..<24).map { _ in
            CelebrationParticle(
                x: screenWidth / 2 + CGFloat.random(in: -60...60),
                y: -20,
                size: CGFloat.random(in: 6...12),
                color: colors.randomElement() ?? .white,
                opacity: 0.0
            )
        }

        for index in celebrationParticles.indices {
            let delay = Double(index) * 0.03
            let endX = CGFloat.random(in: 0...screenWidth)
            let endY = CGFloat.random(in: 180...520)

            withAnimation(AppAnimation.springBouncy.delay(delay)) {
                celebrationParticles[index].x = endX
                celebrationParticles[index].y = endY
                celebrationParticles[index].opacity = Double.random(in: 0.5...0.9)
            }

            withAnimation(AppAnimation.spring.delay(delay + 1.6)) {
                celebrationParticles[index].opacity = 0.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            celebrationParticles.removeAll()
        }
    }
}

// MARK: - Subviews

private struct ResultActionButton: View {
    let icon: String
    let label: String
    let background: Color
    let foreground: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                Text(label)
                    .font(AppFonts.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.md)
            .background(
                LinearGradient(
                    colors: [
                        background.opacity(0.95),
                        background.opacity(0.75)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(AppCornerRadius.md)
            .shadow(color: AppColors.deepShadow.opacity(0.25), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .pressAnimation()
    }
}

private struct ProductSummaryRow: View {
    let product: AffiliateProduct
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(product.name)
                        .font(AppFonts.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                        .lineLimit(2)

                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .semibold))
                        Text("See on Amazon")
                            .font(AppFonts.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(AppColors.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.primary)
            }
            .padding(.vertical, AppSpacing.sm)
            .padding(.horizontal, AppSpacing.md)
            .background(AppColors.surface)
            .cornerRadius(AppCornerRadius.md)
            .shadow(color: AppColors.deepShadow.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .pressAnimation()
    }
}

struct CelebrationParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
}

private struct FullScreenImageView: View {
    let image: UIImage
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.white.opacity(0.85))
                            .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .padding(.top, 48)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .onTapGesture {
            isPresented = false
        }
    }
}

private struct EmailBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var email: String
    @Binding var isSubscribed: Bool
    let onSubmit: () -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    // Drag handle
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                        .padding(.bottom, 20)

                    // Content
                    VStack(spacing: 16) {
                        Text("Want 10 More Designs?")
                            .font(AppFonts.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.text)

                        Text("Enter your email to unlock 10 additional AI-generated Christmas designs")
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.text.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        // Email input
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("your@email.com", text: $email)
                                .textFieldStyle(PlainTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(AppCornerRadius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                        .stroke(AppColors.goldAccent.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, AppSpacing.xl)

                        // Submit button
                        Button(action: {
                            onSubmit()
                            withAnimation(.spring()) {
                                isPresented = false
                            }
                        }) {
                            Text("Get 10 More Designs")
                                .font(AppFonts.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.goldAccent)
                                .cornerRadius(AppCornerRadius.md)
                        }
                        .padding(.horizontal, AppSpacing.xl)
                        .disabled(email.isEmpty)
                        .opacity(email.isEmpty ? 0.5 : 1.0)

                        // Dismiss button
                        Button(action: {
                            withAnimation(.spring()) {
                                isPresented = false
                            }
                        }) {
                            Text("Maybe Later")
                                .font(AppFonts.callout)
                                .foregroundColor(AppColors.text.opacity(0.6))
                        }
                        .padding(.bottom, AppSpacing.md)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xl)
                }
                .frame(maxWidth: .infinity)
                .background(AppColors.background)
                .cornerRadius(AppCornerRadius.xl, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: -5)
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 100 {
                                withAnimation(.spring()) {
                                    isPresented = false
                                }
                            }
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color.black.opacity(isPresented ? 0.3 : 0)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
}

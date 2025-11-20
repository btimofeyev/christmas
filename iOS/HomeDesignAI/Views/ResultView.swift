//
//  ResultView.swift
//  HomeDesignAI
//
//  Festive result screen with single-view layout
//

import SwiftUI
import AVKit

struct ResultView: View {
    @ObservedObject var viewModel: HomeDesignViewModel
    @State private var showShareSheet = false
    @State private var showingOriginal = false
    @State private var showFullScreen = false
    @State private var celebrationParticles: [CelebrationParticle] = []
    @State private var showCelebration = false
    @State private var showReferralSheet = false
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
                        icon: "play.rectangle.on.rectangle",
                        label: "Story +10",
                        background: AppColors.surface,
                        foreground: AppColors.primary,
                        isLoading: viewModel.isCreatingVideo,
                        loadingLabel: "Creating"
                    ) {
                        viewModel.createAndShareVideo()
                    }
                    .accessibilityLabel("Share before and after video")
                    .accessibilityHint("Create an Instagram-ready video and earn +10 more designs")
                    .disabled(viewModel.isCreatingVideo || viewModel.decoratedImage == nil)

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

                // Invite Friends Button
                Button(action: {
                    showReferralSheet = true
                    viewModel.generateOrGetReferralCode()
                }) {
                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 18, weight: .semibold))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Invite Friends")
                                .font(AppFonts.headline)
                                .fontWeight(.semibold)

                            Text("Get +\(AppConfig.referralRewardAmount) designs each")
                                .font(AppFonts.caption)
                                .opacity(0.85)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .opacity(0.5)
                    }
                    .foregroundColor(AppColors.primary)
                    .padding(AppSpacing.md)
                    .background(AppColors.accent)
                    .cornerRadius(AppCornerRadius.md)
                    .shadow(color: AppColors.deepShadow.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .accessibilityLabel("Invite friends to earn more designs")
                .accessibilityHint("Share your referral link and both earn +\(AppConfig.referralRewardAmount) designs")
                .opacity(showCelebration ? 1.0 : 0.0)
                .animation(AppAnimation.spring.delay(0.75), value: showCelebration)

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

            // About button in top-left corner - temporarily disabled
            // TODO: Uncomment when AboutView is added to Xcode project
            // VStack {
            //     HStack {
            //         Button(action: { showAbout = true }) {
            //             Image(systemName: "info.circle.fill")
            //                 .font(.system(size: 28))
            //                 .foregroundColor(.white.opacity(0.9))
            //                 .background(
            //                     Circle()
            //                         .fill(Color.black.opacity(0.2))
            //                         .frame(width: 34, height: 34)
            //                 )
            //         }
            //         .accessibilityLabel("About")
            //         .accessibilityHint("View app information, privacy policy, and terms of service")
            //         .padding(.top, 50)
            //         .padding(.leading, 20)
            //         Spacer()
            //     }
            //     Spacer()
            // }

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
        .sheet(isPresented: $viewModel.showVideoPreview, onDismiss: {
            viewModel.cleanupVideoShare()
        }) {
            if let videoURL = viewModel.videoURL {
                VideoPreviewSheet(
                    videoURL: videoURL,
                    shareAction: {
                        viewModel.handleVideoStoryShareTapped()
                    },
                    closeAction: {
                        viewModel.cleanupVideoShare()
                    }
                )
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
        // TODO: Uncomment when AboutView is added to Xcode project
        // .sheet(isPresented: $showAbout) {
        //     AboutView()
        // }
        .sheet(isPresented: $showReferralSheet) {
            ReferralBottomSheet(viewModel: viewModel)
        }
        .onAppear {
            withAnimation {
                showCelebration = true
            }

            if !reduceMotion {
                generateCelebrationParticles()
            }

            // Auto-show referral prompt if user is running low on generations
            if viewModel.generationsRemaining <= 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.spring()) {
                        showReferralSheet = true
                        viewModel.generateOrGetReferralCode()
                    }
                }
            }

            // Request review at milestone generations (3rd, 5th)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                ReviewRequestManager.shared.requestReviewIfAppropriate(
                    event: .successfulGeneration,
                    generationCount: viewModel.totalDesignsGenerated
                )
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
    var isLoading: Bool = false
    var loadingLabel: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(foreground)
                    Text(loadingLabel ?? label)
                        .font(AppFonts.caption)
                        .fontWeight(.semibold)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                    Text(label)
                        .font(AppFonts.caption)
                        .fontWeight(.semibold)
                }
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
        .disabled(isLoading)
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

private struct VideoPreviewSheet: View {
    let videoURL: URL
    let shareAction: () -> Void
    let closeAction: () -> Void

    @State private var player: AVPlayer
    @State private var isShowingShare = false

    init(videoURL: URL, shareAction: @escaping () -> Void, closeAction: @escaping () -> Void) {
        self.videoURL = videoURL
        self.shareAction = shareAction
        self.closeAction = closeAction
        _player = State(initialValue: AVPlayer(url: videoURL))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: AppSpacing.lg) {
                VideoPlayer(player: player)
                    .frame(maxWidth: .infinity)
                    .frame(height: 420)
                    .cornerRadius(AppCornerRadius.lg)
                    .shadow(color: AppColors.deepShadow.opacity(0.25), radius: 20, x: 0, y: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }

                Text("Preview your share-ready Story clip before posting it to Instagram, TikTok, or Messages. Sharing unlocks +\(AppConfig.videoShareRewardAmount) bonus designs instantly.")
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.text)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: AppSpacing.md) {
                    Button {
                        player.pause()
                        isShowingShare = true
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: "square.and.arrow.up.on.square.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Share Story")
                                .font(AppFonts.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.accent)
                        .cornerRadius(AppCornerRadius.md)
                        .shadow(color: AppColors.deepShadow.opacity(0.2), radius: 10, x: 0, y: 6)
                    }

                    Button {
                        player.pause()
                        closeAction()
                    } label: {
                        Text("Done")
                            .font(AppFonts.body)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.surface)
                            .cornerRadius(AppCornerRadius.md)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Story Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        player.pause()
                        closeAction()
                    }
                    .font(AppFonts.body)
                }
            }
        }
        .sheet(isPresented: $isShowingShare, onDismiss: {
            player.play()
        }) {
            ShareSheet(
                items: [
                    videoURL,
                    "Before ➡️ After with HomeDesign AI 🎄 Instantly redecorate your space: \(AppConfig.storyShareUrl)"
                ],
                completion: { completed in
                    if completed {
                        shareAction()
                    }
                }
            )
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

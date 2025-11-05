//
//  GeneratingView.swift
//  HomeDesignAI
//
//  Loading screen during AI generation with gift unwrapping animation
//  Follows 2025 Apple Design - delightful, purposeful animations
//

import SwiftUI

struct GeneratingView: View {
    @ObservedObject var viewModel: HomeDesignViewModel
    @State private var animateUnwrap = false
    @State private var ribbonParticles: [RibbonParticle] = []
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            AppGradients.twilight
                .ignoresSafeArea()

            FestiveSnowfallView()

            VStack(spacing: AppSpacing.xl) {
                Spacer()

                if !reduceMotion {
                    ZStack {
                        ForEach(ribbonParticles) { particle in
                            Circle()
                                .fill(particle.color)
                                .frame(width: particle.size, height: particle.size)
                                .offset(x: particle.offsetX, y: particle.offsetY)
                                .opacity(particle.opacity)
                        }

                        GiftBoxView(progress: viewModel.generationProgress, isUnwrapping: animateUnwrap)
                    }
                    .frame(height: 160)
                } else {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.white)
                }

                Text("Creating Your Design")
                    .font(AppFonts.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Our elves are decorating your space with seasonal cheer.")
                    .font(AppFonts.body)
                    .foregroundColor(Color.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)

                VStack(spacing: AppSpacing.sm) {
                    ProgressView(value: viewModel.generationProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accent))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .padding(.horizontal, AppSpacing.xl)

                    Text("\(Int(viewModel.generationProgress * 100))% complete")
                        .font(AppFonts.caption)
                        .foregroundColor(Color.white.opacity(0.8))
                }
                .padding(.top, AppSpacing.lg)

                Spacer()

                VStack(spacing: AppSpacing.md) {
                    TipRow(icon: "lightbulb.fill", text: "Typically under two minutes")
                    TipRow(icon: "lock.fill", text: "Your photo never leaves this session")
                    TipRow(icon: "sparkles", text: "Hang tight for the big reveal!")
                }
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.xxl)
            }
            .padding(.vertical, AppSpacing.lg)
        }
        .onAppear {
            if !reduceMotion {
                animateUnwrap = true
                generateRibbonParticles()

                Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                    generateRibbonParticles()
                }
            }
        }
    }

    private func generateRibbonParticles() {
        let colors = [AppColors.subtleRed, AppColors.primary, AppColors.secondaryAccent]

        ribbonParticles = (0..<12).map { index in
            let angle = Double(index) * (360.0 / 12.0) * .pi / 180.0
            let distance = CGFloat.random(in: 80...120)

            return RibbonParticle(
                offsetX: cos(angle) * distance,
                offsetY: sin(angle) * distance,
                size: CGFloat.random(in: 4...8),
                color: colors.randomElement() ?? AppColors.primary,
                opacity: 0.0,
                createdAt: Date()
            )
        }

        // Animate particles with spring physics
        withAnimation(AppAnimation.spring.delay(0.3)) {
            for index in ribbonParticles.indices {
                ribbonParticles[index].opacity = Double.random(in: 0.3...0.7)
            }
        }

        // Fade out
        withAnimation(AppAnimation.spring.delay(2.0)) {
            for index in ribbonParticles.indices {
                ribbonParticles[index].opacity = 0.0
            }
        }
    }
}

// MARK: - Gift Box View

struct GiftBoxView: View {
    let progress: Double
    let isUnwrapping: Bool

    var body: some View {
        ZStack {
            // Gift box base
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.primary.opacity(0.15))
                .frame(width: 100, height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.primary, lineWidth: 2)
                )

            // Vertical ribbon
            Rectangle()
                .fill(AppColors.subtleRed)
                .frame(width: 12, height: 100)
                .scaleEffect(y: isUnwrapping ? (1.0 - progress * 0.3) : 1.0)
                .animation(AppAnimation.springSmooth, value: progress)

            // Horizontal ribbon
            Rectangle()
                .fill(AppColors.subtleRed)
                .frame(width: 100, height: 12)
                .scaleEffect(x: isUnwrapping ? (1.0 - progress * 0.3) : 1.0)
                .animation(AppAnimation.springSmooth, value: progress)

            // Bow on top
            Image(systemName: "gift.fill")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(AppColors.subtleRed)
                .offset(y: -30)
                .scaleEffect(isUnwrapping ? (1.0 + progress * 0.2) : 1.0)
                .rotationEffect(.degrees(isUnwrapping ? progress * 20 : 0))
                .animation(AppAnimation.springBouncy, value: progress)

            // Progress indicator embedded in box
            Circle()
                .trim(from: 0, to: progress)
                .stroke(AppColors.primary, lineWidth: 3)
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(AppAnimation.springSmooth, value: progress)
        }
        .scaleEffect(isUnwrapping ? (1.0 + sin(Date().timeIntervalSinceReferenceDate * 2) * 0.02) : 1.0)
    }
}

// MARK: - Ribbon Particle

struct RibbonParticle: Identifiable {
    let id = UUID()
    var offsetX: CGFloat
    var offsetY: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
    let createdAt: Date
}

// MARK: - Tip Row

struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppColors.accent)
                .frame(width: 20)

            Text(text)
                .font(AppFonts.caption)
                .foregroundColor(Color.white.opacity(0.8))

            Spacer()
        }
    }
}

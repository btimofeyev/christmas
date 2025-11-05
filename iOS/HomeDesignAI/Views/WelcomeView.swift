//
//  WelcomeView.swift
//  HomeDesignAI
//
//  Welcome screen with app intro and CTA
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: HomeDesignViewModel

    var body: some View {
        ZStack {
            backgroundLayer
                .ignoresSafeArea()

            FestiveSnowfallView()

            VStack(spacing: AppSpacing.lg) {
                Spacer()

                // Icon + Brand
                VStack(spacing: AppSpacing.sm) {
                    heroArtwork

                    Text(AppConfig.appName)
                        .font(AppFonts.largeTitle)
                        .foregroundColor(.white)

                    Text("Holiday Magic On Every Space")
                        .font(AppFonts.title3)
                        .foregroundColor(Color.white.opacity(0.85))
                }

                // Short marketing copy
                Text("Capture your room, choose a vibe, and our elves instantly decorate it with festive cheer.")
                    .font(AppFonts.callout)
                    .foregroundColor(Color.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)

                // Feature highlights
                HStack(spacing: AppSpacing.md) {
                    FeatureBadge(icon: "camera.fill", title: "Snap")
                    FeatureBadge(icon: "sparkles", title: "Transform")
                    FeatureBadge(icon: "bag.fill", title: "Shop")
                }

                Spacer()

                Button(action: {
                    viewModel.goToStep(.uploadPhoto)
                }) {
                    Text("Start Decorating")
                        .font(AppFonts.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.95),
                                    Color.white.opacity(0.82)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(AppCornerRadius.lg)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                                .stroke(Color.white.opacity(0.35), lineWidth: 1)
                        )
                        .shadow(color: AppColors.deepShadow.opacity(0.18), radius: 16, x: 0, y: 10)
                }
                .pressAnimation()

                Text("No account required · Instant results")
                    .font(AppFonts.caption)
                    .foregroundColor(Color.white.opacity(0.8))

                Spacer(minLength: AppSpacing.lg)
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, AppSpacing.lg)
        }
    }
}

// MARK: - Feature Badge

struct FeatureBadge: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.primary)
                .frame(width: 44, height: 44)
                .background(AppColors.surface)
                .cornerRadius(22)

            Text(title)
                .font(AppFonts.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.85))
        }
    }
}

// MARK: - Private Subviews

private extension WelcomeView {
    @ViewBuilder
    var backgroundLayer: some View {
        if let backdrop = UIImage(named: "HolidayBackdrop") {
            Image(uiImage: backdrop)
                .resizable()
                .scaledToFill()
        } else {
            AppGradients.festive
        }
    }

    @ViewBuilder
    var heroArtwork: some View {
        if let logo = UIImage(named: "logo") {
            Image(uiImage: logo)
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                .shadow(color: AppColors.deepShadow.opacity(0.3), radius: 20, x: 0, y: 12)
        } else {
            ZStack {
                Circle()
                    .fill(AppColors.snow)
                    .frame(width: 120, height: 120)
                    .shadow(color: AppColors.deepShadow.opacity(0.15), radius: 10, x: 0, y: 6)

                Image(systemName: "house.and.tree.fill")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundColor(.white)
                    .shadow(color: AppColors.deepShadow, radius: 12, x: 0, y: 6)
            }
        }
    }
}

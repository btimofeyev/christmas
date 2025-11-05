//
//  SceneSelectionView.swift
//  HomeDesignAI
//
//  Festive scene selection without scrolling
//

import SwiftUI

struct SceneSelectionView: View {
    @ObservedObject var viewModel: HomeDesignViewModel

    var body: some View {
        ZStack {
            AppGradients.festive
                .ignoresSafeArea()

            FestiveSnowfallView()

            VStack(spacing: AppSpacing.lg) {
                Spacer()

                VStack(spacing: AppSpacing.xs) {
                    Text("Where is the magic happening?")
                        .font(AppFonts.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Pick the scene and we will match the perfect holiday look.")
                        .font(AppFonts.callout)
                        .foregroundColor(Color.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xl)
                }

                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(AppCornerRadius.lg)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: AppColors.deepShadow.opacity(0.3), radius: 18, x: 0, y: 12)
                        .padding(.horizontal, AppSpacing.xl)
                }

                HStack(spacing: AppSpacing.md) {
                    ForEach(SceneType.allCases, id: \.self) { scene in
                        SceneOptionButton(
                            scene: scene,
                            isSelected: viewModel.selectedScene == scene
                        ) {
                            viewModel.selectScene(scene)
                        }
                    }
                }

                VStack(spacing: AppSpacing.xs) {
                    Text("Decorate for")
                        .font(AppFonts.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.white.opacity(0.85))

                    HStack(spacing: AppSpacing.md) {
                        ForEach(HomeDesignViewModel.LightingMode.allCases, id: \.self) { mode in
                            Button(action: {
                                withAnimation(AppAnimation.standard) {
                                    viewModel.lightingMode = mode
                                }
                            }) {
                                VStack(spacing: AppSpacing.xs) {
                                    Image(systemName: mode.icon)
                                        .font(.system(size: 20, weight: .semibold))
                                    Text(mode.displayName)
                                        .font(AppFonts.caption)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(viewModel.lightingMode == mode ? AppColors.primary : Color.white.opacity(0.85))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.md)
                                .background(
                                    viewModel.lightingMode == mode
                                    ? AppColors.surface
                                    : AppColors.surface.opacity(0.15)
                                )
                                .cornerRadius(AppCornerRadius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .pressAnimation()
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.md)

                Button(action: {
                    viewModel.goToStep(.styleSelection)
                }) {
                    Text("Continue to Styles")
                        .font(AppFonts.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.md)
                        .background(AppColors.surface)
                        .cornerRadius(AppCornerRadius.lg)
                        .shadow(color: AppColors.deepShadow.opacity(0.25), radius: 14, x: 0, y: 8)
                }
                .pressAnimation()
                .padding(.horizontal, AppSpacing.md)

                Spacer()

                Button(action: {
                    viewModel.goToStep(.uploadPhoto)
                }) {
                    Text("Back to Photos")
                        .font(AppFonts.callout)
                        .foregroundColor(Color.white.opacity(0.8))
                        .padding(.vertical, AppSpacing.sm)
                        .padding(.horizontal, AppSpacing.lg)
                }
                .pressAnimation()

                Spacer(minLength: AppSpacing.lg)
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, AppSpacing.lg)
        }
    }
}

// MARK: - Scene Option Button

struct SceneOptionButton: View {
    let scene: SceneType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.sm) {
                Image(systemName: scene.icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(AppColors.primary)
                    .frame(width: 64, height: 64)
                    .background(AppColors.surface)
                    .cornerRadius(22)
                    .shadow(color: AppColors.deepShadow.opacity(0.18), radius: 10, x: 0, y: 6)

                Text(scene.displayName)
                    .font(AppFonts.headline)
                    .foregroundColor(.white)

                Text(scene.description)
                    .font(AppFonts.caption)
                    .foregroundColor(Color.white.opacity(0.75))
            }
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.lg)
            .background(isSelected ? AppColors.surface.opacity(0.25) : AppColors.surface.opacity(0.15))
            .cornerRadius(AppCornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(
                        isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.25),
                        lineWidth: 2
                    )
            )
            .shadow(color: AppColors.deepShadow.opacity(0.25), radius: isSelected ? 16 : 10, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .pressAnimation()
    }
}

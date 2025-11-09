//
//  StyleSelectionView.swift
//  HomeDesignAI
//
//  Festive preset selection without scrolling
//

import SwiftUI

struct StyleSelectionView: View {
    @ObservedObject var viewModel: HomeDesignViewModel
    @State private var customPromptText = ""
    @State private var showCustomSheet = false
    @FocusState private var isPromptFocused: Bool

    private let styleRows: [[DecorStyle]] = [
        [.classicChristmas, .nordicMinimalist],
        [.modernSilver, .cozyFamily],
        [.rusticFarmhouse, .elegantGold]
    ]

    var body: some View {
        ZStack {
            AppGradients.twilight
                .ignoresSafeArea()

            FestiveSnowfallView()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.md) {
                    VStack(spacing: AppSpacing.xs) {
                        Text("Choose your festive vibe")
                            .font(AppFonts.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Tap a preset or describe the look you want.")
                            .font(AppFonts.callout)
                            .foregroundColor(Color.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.xl)
                    }
                    .padding(.top, AppSpacing.xl)

                    GenerationsBadge(count: viewModel.generationsRemaining)

                    IntensitySelectionRow(selected: viewModel.decorationIntensity) { intensity in
                        withAnimation(AppAnimation.standard) {
                            viewModel.decorationIntensity = intensity
                        }
                    }

                    ForEach(styleRows, id: \.self) { row in
                    HStack(spacing: AppSpacing.md) {
                        ForEach(row, id: \.self) { style in
                            StyleChoiceCard(
                                style: style,
                                isSelected: viewModel.selectedStyle == style
                            ) {
                                viewModel.selectStyle(style)
                            }
                        }
                    }
                }

                    Button(action: {
                        viewModel.goToStep(.sceneSelection)
                    }) {
                        Text("Back to Scene Selection")
                            .font(AppFonts.callout)
                            .foregroundColor(Color.white.opacity(0.8))
                            .padding(.vertical, AppSpacing.sm)
                            .padding(.horizontal, AppSpacing.lg)
                    }
                    .pressAnimation()
                    .padding(.bottom, AppSpacing.xl)
                }
                .padding(.horizontal, AppSpacing.xl)
            }

            // Floating Custom Style Button
            VStack {
                Spacer()
                Button(action: {
                    showCustomSheet = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Custom Style")
                            .font(AppFonts.callout)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(AppColors.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)
                    .background(AppColors.surface)
                    .cornerRadius(AppCornerRadius.lg)
                    .shadow(color: AppColors.deepShadow.opacity(0.3), radius: 16, x: 0, y: 8)
                }
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.lg)
                .pressAnimation()
            }
        }
        .sheet(isPresented: $showCustomSheet) {
            CustomStyleSheet(
                prompt: $customPromptText,
                isFocused: _isPromptFocused,
                onSubmit: {
                    viewModel.selectCustomStyle(prompt: customPromptText)
                    showCustomSheet = false
                }
            )
        }
        .onChange(of: viewModel.selectedStyle) { newValue in
            if newValue != .custom {
                customPromptText = ""
            }
        }
        .onAppear {
            customPromptText = viewModel.customPrompt
        }
        .onChange(of: customPromptText) { newValue in
            viewModel.customPrompt = newValue
        }
    }
}

// MARK: - Subviews

private struct GenerationsBadge: View {
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
            Text("\(count) designs remaining")
                .fontWeight(.semibold)
        }
        .font(AppFonts.caption)
        .foregroundColor(AppColors.primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(AppColors.surface)
        .cornerRadius(20)
        .shadow(color: AppColors.deepShadow.opacity(0.2), radius: 10, x: 0, y: 6)
    }
}

private struct StyleChoiceCard: View {
    let style: DecorStyle
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Image(systemName: style.icon)
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.primary)
                    .padding(10)
                    .background(AppColors.surface)
                    .cornerRadius(14)
                    .shadow(color: AppColors.deepShadow.opacity(0.12), radius: 8, x: 0, y: 6)

                Text(style.displayName)
                    .font(AppFonts.headline)
                    .foregroundColor(.white)

                Text(style.description)
                    .font(AppFonts.caption)
                    .foregroundColor(Color.white.opacity(0.75))
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(isSelected ? AppColors.surface.opacity(0.25) : AppColors.surface.opacity(0.12))
            .cornerRadius(AppCornerRadius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(
                        isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.2),
                        lineWidth: 2
                    )
            )
            .shadow(color: AppColors.deepShadow.opacity(0.25), radius: isSelected ? 14 : 10, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .pressAnimation()
    }
}

private struct IntensitySelectionRow: View {
    let selected: DecorationIntensity
    let onSelect: (DecorationIntensity) -> Void

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                Text("Decoration Intensity")
                    .font(AppFonts.caption)
                    .fontWeight(.semibold)
            }
            .foregroundColor(Color.white.opacity(0.85))

            HStack(spacing: AppSpacing.xs) {
                ForEach(DecorationIntensity.allCases, id: \.self) { intensity in
                    Button(action: {
                        onSelect(intensity)
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: intensity.icon)
                                .font(.system(size: 16, weight: .semibold))
                            Text(intensity.displayName)
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(selected == intensity ? AppColors.primary : Color.white.opacity(0.75))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selected == intensity
                            ? AppColors.surface
                            : AppColors.surface.opacity(0.1)
                        )
                        .cornerRadius(AppCornerRadius.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                .stroke(
                                    selected == intensity ? AppColors.primary.opacity(0.5) : Color.white.opacity(0.15),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .pressAnimation()
                }
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColors.surface.opacity(0.12))
        .cornerRadius(AppCornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct CustomStyleSheet: View {
    @Binding var prompt: String
    @FocusState var isFocused: Bool
    let onSubmit: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                AppGradients.twilight
                    .ignoresSafeArea()

                VStack(spacing: AppSpacing.lg) {
                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.primary)
                            .padding(.top, AppSpacing.xl)

                        Text("Custom Style")
                            .font(AppFonts.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Describe the festive look you envision")
                            .font(AppFonts.callout)
                            .foregroundColor(Color.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: AppSpacing.md) {
                        TextField("e.g. Cozy cabin with twinkling fairy lights and woodland creatures", text: $prompt)
                            .focused($isFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                if !prompt.isEmpty {
                                    onSubmit()
                                }
                            }
                            .padding()
                            .background(AppColors.surface)
                            .cornerRadius(AppCornerRadius.md)
                            .foregroundColor(AppColors.primary)

                        Button(action: {
                            onSubmit()
                        }) {
                            Text("Design My Custom Look")
                                .font(AppFonts.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.md)
                                .background(AppColors.surface)
                                .cornerRadius(AppCornerRadius.md)
                                .opacity(prompt.isNotEmpty ? 1 : 0.4)
                                .shadow(color: AppColors.deepShadow.opacity(0.2), radius: 12, x: 0, y: 6)
                        }
                        .disabled(prompt.isEmpty)
                        .pressAnimation()
                    }

                    Spacer()
                }
                .padding(.horizontal, AppSpacing.xl)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

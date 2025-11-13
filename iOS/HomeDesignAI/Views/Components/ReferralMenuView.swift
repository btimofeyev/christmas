//
//  ReferralMenuView.swift
//  HomeDesignAI
//
//  Menu for referral code actions
//

import SwiftUI

struct ReferralMenuView: View {
    @ObservedObject var viewModel: HomeDesignViewModel
    @Environment(\.dismiss) private var dismiss
    let onEnterCode: () -> Void
    let onShareCode: () -> Void

    var body: some View {
        ZStack {
            AppGradients.twilight
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.xl) {
                // Header
                VStack(spacing: AppSpacing.xs) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.primary)
                        .padding(.top, AppSpacing.lg)

                    Text("Earn Free Designs")
                        .font(AppFonts.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                // Options
                VStack(spacing: AppSpacing.md) {
                    // Enter Code Option
                    Button(action: {
                        onEnterCode()
                    }) {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            HStack {
                                Image(systemName: "keyboard.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.primary)

                                Text("Enter a Friend's Code")
                                    .font(AppFonts.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.primary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.primary.opacity(0.6))
                            }

                            Text("Get +3 designs instantly")
                                .font(AppFonts.caption)
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                                .padding(.leading, 28)
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.surface)
                        .cornerRadius(AppCornerRadius.md)
                        .shadow(color: AppColors.deepShadow.opacity(0.2), radius: 8, x: 0, y: 4)
                    }

                    // Share Code Option
                    Button(action: {
                        onShareCode()
                    }) {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            HStack {
                                Image(systemName: "square.and.arrow.up.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.primary)

                                Text("Share My Code")
                                    .font(AppFonts.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.primary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.primary.opacity(0.6))
                            }

                            Text("Get +3 designs per friend")
                                .font(AppFonts.caption)
                                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                                .padding(.leading, 28)
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.surface)
                        .cornerRadius(AppCornerRadius.md)
                        .shadow(color: AppColors.deepShadow.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, AppSpacing.xl)

                // Info Text
                Text("\(viewModel.generationsRemaining) designs remaining")
                    .font(AppFonts.caption)
                    .foregroundColor(.white.opacity(0.6))

                Spacer()

                // Cancel Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(AppFonts.callout)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.vertical, AppSpacing.sm)
                }
                .padding(.bottom, AppSpacing.lg)
            }
        }
    }
}

#Preview {
    ReferralMenuView(
        viewModel: HomeDesignViewModel(),
        onEnterCode: {},
        onShareCode: {}
    )
}

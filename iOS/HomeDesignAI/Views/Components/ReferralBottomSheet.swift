//
//  ReferralBottomSheet.swift
//  HomeDesignAI
//
//  Bottom sheet for inviting friends via referral link
//

import SwiftUI

struct ReferralBottomSheet: View {
    @ObservedObject var viewModel: HomeDesignViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showShareSheet = false

    var body: some View {
        NavigationView {
            VStack(spacing: AppSpacing.lg) {
                // Header Icon
                Image(systemName: "gift.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(AppColors.accent)
                    .padding(.top, AppSpacing.lg)

                // Title
                Text("Invite Friends, Get More Designs!")
                    .font(AppFonts.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.text)
                    .multilineTextAlignment(.center)

                // Description
                VStack(spacing: AppSpacing.sm) {
                    Text("Share your referral link with friends")
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.text.opacity(0.7))
                        .multilineTextAlignment(.center)

                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "person.fill")
                            .foregroundColor(AppColors.secondary)

                        Text("Your friend gets +\(AppConfig.referralRewardAmount) designs")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.text)

                        Spacer()
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.surface)
                    .cornerRadius(AppCornerRadius.md)

                    HStack(spacing: AppSpacing.sm) {
                        Image(systemName: "gift.fill")
                            .foregroundColor(AppColors.accent)

                        Text("You get +\(AppConfig.referralRewardAmount) designs")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.text)

                        Spacer()
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.surface)
                    .cornerRadius(AppCornerRadius.md)
                }
                .padding(.horizontal, AppSpacing.lg)

                // Referral Code Display (if generated)
                if let code = viewModel.myReferralCode {
                    VStack(spacing: AppSpacing.xs) {
                        Text("Your Referral Code")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.text.opacity(0.6))

                        Text(code)
                            .font(.system(.title3, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                            .padding(AppSpacing.sm)
                            .background(AppColors.surface)
                            .cornerRadius(AppCornerRadius.sm)
                    }
                    .padding(.top, AppSpacing.sm)
                }

                Spacer()

                // Share Button
                Button(action: {
                    showShareSheet = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .semibold))

                        Text("Share Invite Link")
                            .font(AppFonts.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.accent)
                    .cornerRadius(AppCornerRadius.md)
                    .shadow(color: AppColors.deepShadow.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, AppSpacing.xl)
                .disabled(viewModel.isGeneratingReferralCode)
                .opacity(viewModel.isGeneratingReferralCode ? 0.5 : 1.0)
                .sheet(isPresented: $showShareSheet) {
                    viewModel.shareReferralLink()
                }

                // Generations Remaining
                Text("\(viewModel.generationsRemaining) designs remaining")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.text.opacity(0.5))
                    .padding(.bottom, AppSpacing.lg)
            }
            .padding()
            .background(AppColors.background)
            .navigationTitle("Earn More Designs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
        .onAppear {
            // Generate code if not already done
            viewModel.generateOrGetReferralCode()
        }
    }
}

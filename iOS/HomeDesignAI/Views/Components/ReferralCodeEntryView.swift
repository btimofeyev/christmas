//
//  ReferralCodeEntryView.swift
//  HomeDesignAI
//
//  Alert for entering referral codes manually
//

import SwiftUI

struct ReferralCodeEntryView: View {
    @ObservedObject var viewModel: HomeDesignViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                AppGradients.twilight
                    .ignoresSafeArea()

                VStack(spacing: AppSpacing.lg) {
                    VStack(spacing: AppSpacing.xs) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.primary)
                            .padding(.top, AppSpacing.xl)

                        Text("Enter Referral Code")
                            .font(AppFonts.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Get 3 free designs when you enter a valid referral code!")
                            .font(AppFonts.callout)
                            .foregroundColor(Color.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.md)
                    }

                    VStack(spacing: AppSpacing.md) {
                        TextField("Enter 6-character code", text: $viewModel.referralCodeInput)
                            .textCase(.uppercase)
                            .keyboardType(.asciiCapable)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                            .font(.system(size: 24, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(AppColors.surface)
                            .cornerRadius(AppCornerRadius.md)
                            .foregroundColor(AppColors.primary)

                        Button(action: {
                            viewModel.enterReferralCodeManually(code: viewModel.referralCodeInput)
                            dismiss()
                        }) {
                            HStack {
                                if viewModel.isClaimingReferral {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                                        .scaleEffect(0.8)
                                }

                                Text(viewModel.isClaimingReferral ? "Claiming..." : "Claim Rewards")
                                    .font(AppFonts.callout)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(AppColors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.md)
                            .background(AppColors.surface)
                            .cornerRadius(AppCornerRadius.md)
                            .opacity(viewModel.referralCodeInput.isEmpty ? 0.4 : 1)
                            .shadow(color: AppColors.deepShadow.opacity(0.2), radius: 12, x: 0, y: 6)
                        }
                        .disabled(viewModel.referralCodeInput.isEmpty || viewModel.isClaimingReferral)
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
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    ReferralCodeEntryView(viewModel: HomeDesignViewModel())
}
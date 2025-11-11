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
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 12) {
                    Text("🎁")
                        .font(.system(size: 60))

                    Text("Enter Referral Code")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("Get 3 free designs when you enter a valid referral code!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Code Input
                VStack(spacing: 16) {
                    Text("Referral Code")
                        .font(.headline)
                        .foregroundColor(.primary)

                    TextField("Enter 6-character code", text: $viewModel.referralCodeInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textCase(.uppercase)
                        .keyboardType(.asciiCapable)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()

                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.enterReferralCodeManually(code: viewModel.referralCodeInput)
                        dismiss()
                    }) {
                        HStack {
                            if viewModel.isClaimingReferral {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }

                            Text(viewModel.isClaimingReferral ? "Claiming..." : "Claim Code")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.referralCodeInput.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.referralCodeInput.isEmpty || viewModel.isClaimingReferral)

                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(30)
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
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
//
//  NoGenerationsView.swift
//  HomeDesignAI
//
//  View shown when user has no generations remaining
//

import SwiftUI

struct NoGenerationsView: View {
    @ObservedObject var viewModel: HomeDesignViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {

                // Header
                VStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.1))
                            .frame(width: 80, height: 80)

                        Image(systemName: "gift.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                    }

                    // Title
                    Text("Out of Free Designs")
                        .font(.title2)
                        .fontWeight(.bold)

                    // Subtitle
                    Text("You've used all your free designs! Share with friends to earn more.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)

                Spacer()

                // Referral Info
                VStack(spacing: 16) {
                    // Benefit card
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                            .frame(width: 44)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Invite a Friend")
                                .font(.headline)
                            Text("Both of you get +\(AppConfig.referralRewardAmount) free designs")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)

                    // Current stats
                    if viewModel.totalDesignsGenerated > 0 {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.orange)

                            Text("You've created **\(viewModel.totalDesignsGenerated)** designs so far!")
                                .font(.subheadline)

                            Spacer()
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Action Buttons
                VStack(spacing: 12) {
                    // Share button
                    Button {
                        // Generate referral code if needed
                        if viewModel.myReferralCode == nil {
                            viewModel.generateOrGetReferralCode()
                        }

                        // Show share sheet after a brief delay (to allow code generation)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showShareSheet = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.headline)
                            Text("Share & Earn +\(AppConfig.referralRewardAmount) Designs")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }

                    // Dismiss button
                    Button {
                        dismiss()
                    } label: {
                        Text("Maybe Later")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .navigationTitle("Earn More Designs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            viewModel.shareReferralLink()
        }
    }
}

#Preview {
    NoGenerationsView(viewModel: HomeDesignViewModel())
}

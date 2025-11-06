import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Festive gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.83, green: 0.18, blue: 0.18), // Christmas red
                    Color(red: 0.11, green: 0.37, blue: 0.13)  // Christmas green
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundColor(.white)

                        Text("HomeDesign AI")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)

                        Text("Holiday Edition")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))

                        Text("Version 1.0 (Build 1)")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.top, 40)

                    // Description
                    VStack(spacing: 16) {
                        Text("Transform your home with AI-powered Christmas decoration visualization")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Powered By Section
                    VStack(spacing: 20) {
                        Text("Powered By")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)

                        VStack(spacing: 16) {
                            InfoCard(
                                icon: "cpu.fill",
                                title: "Google Gemini AI",
                                description: "Advanced AI technology for image generation and analysis"
                            )

                            InfoCard(
                                icon: "cart.fill",
                                title: "Amazon Affiliate Program",
                                description: "Shop curated holiday decorations to bring your vision to life"
                            )
                        }
                    }
                    .padding(.horizontal)

                    // Legal Links Section
                    VStack(spacing: 20) {
                        Text("Legal & Information")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)

                        VStack(spacing: 12) {
                            if let privacyURL = URL(string: "https://christmas-production-18fe.up.railway.app/privacy") {
                                Link(destination: privacyURL) {
                                    LegalLinkCard(
                                        icon: "lock.shield.fill",
                                        title: "Privacy Policy",
                                        subtitle: "How we protect your data"
                                    )
                                }
                            }

                            if let termsURL = URL(string: "https://christmas-production-18fe.up.railway.app/terms") {
                                Link(destination: termsURL) {
                                    LegalLinkCard(
                                        icon: "doc.text.fill",
                                        title: "Terms of Service",
                                        subtitle: "Usage terms and conditions"
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Disclaimer
                    VStack(spacing: 12) {
                        Text("Affiliate Disclosure")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Text("As an Amazon Associate we earn from qualifying purchases. AI-generated images are for visualization purposes only and may not reflect actual decoration results.")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 10)

                    // Made with love
                    VStack(spacing: 8) {
                        Text("Made with ❤️ for the holidays")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))

                        Text("© 2024 HomeDesign AI")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.9))
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.2))
                                    .frame(width: 36, height: 36)
                            )
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Supporting Views

struct InfoCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
        )
    }
}

struct LegalLinkCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.2))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
        )
    }
}

#Preview {
    AboutView()
}

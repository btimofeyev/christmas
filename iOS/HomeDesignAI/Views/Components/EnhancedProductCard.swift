//
//  EnhancedProductCard.swift
//  HomeDesignAI
//
//  Enhanced product card for horizontal carousel shopping
//

import SwiftUI

struct EnhancedProductCard: View {
    let product: AffiliateProduct
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                // Product Image (Larger, more prominent)
                AsyncImage(url: URL(string: product.image)) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            ProgressView()
                                .tint(AppColors.goldAccent)
                        }
                        .frame(width: 280, height: 200)

                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 280, height: 200)
                            .clipped()

                    case .failure:
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                        .frame(width: 280, height: 200)

                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(AppCornerRadius.md)

                // Product Info
                VStack(alignment: .leading, spacing: 10) {
                    Text(product.name)
                        .font(AppFonts.body)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.text)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(height: 40, alignment: .top)

                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .semibold))
                        Text("See it on Amazon")
                            .font(AppFonts.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(AppColors.secondary)

                    // Shop Now Button
                    HStack {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 14))
                        Text("Shop on Amazon")
                            .font(AppFonts.callout)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.goldAccent)
                    .cornerRadius(AppCornerRadius.sm)
                }
                .padding(.horizontal, AppSpacing.sm)
                .padding(.bottom, AppSpacing.sm)
            }
            .frame(width: 280)
            .background(
                LinearGradient(
                    colors: [
                        AppColors.cardBackground.opacity(0.95),
                        AppColors.cardBackground.opacity(0.7)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(AppCornerRadius.lg)
            .shadow(color: Color.black.opacity(0.1), radius: 16, x: 0, y: 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

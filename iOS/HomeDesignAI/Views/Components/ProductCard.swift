//
//  ProductCard.swift
//  HomeDesignAI
//
//  Card displaying affiliate product with text only
//

import SwiftUI

struct ProductCard: View {
    let product: AffiliateProduct
    let onTap: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .center, spacing: 12) {
                // Product Name
                Text(product.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.text)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)

                // CTA Button
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .bold))
                    Text("Open on Amazon")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [
                            AppColors.goldAccent,
                            AppColors.goldAccent.opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(8)
            }
            .frame(width: 140)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(
                LinearGradient(
                    colors: [
                        AppColors.cardBackground.opacity(0.95),
                        AppColors.cardBackground.opacity(0.7)
                    ],
                    startPoint: .top,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(AppCornerRadius.md)
            .shadow(color: Color.black.opacity(isPressed ? 0.12 : 0.08), radius: isPressed ? 4 : 6, x: 0, y: isPressed ? 1 : 2)
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

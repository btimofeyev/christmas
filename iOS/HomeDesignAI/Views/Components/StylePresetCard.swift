//
//  StylePresetCard.swift
//  HomeDesignAI
//
//  Card for style preset selection
//

import SwiftUI

struct StylePresetCard: View {
    let style: DecorStyle
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: AppSpacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(style.accentColor.opacity(0.15))
                        .frame(width: 80, height: 80)

                    Image(systemName: style.icon)
                        .font(.system(size: 32))
                        .foregroundColor(style.accentColor)
                }

                // Title
                Text(style.displayName)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.text)
                    .multilineTextAlignment(.center)

                // Description
                Text(style.description)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.text.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity)
            .background(AppColors.cardBackground)
            .cornerRadius(AppCornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(
                        isSelected ? style.accentColor : Color.clear,
                        lineWidth: 3
                    )
            )
            .shadow(
                color: isSelected ? style.accentColor.opacity(0.3) : Color.black.opacity(0.06),
                radius: isSelected ? 8 : 6,
                x: 0,
                y: 2
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(AppAnimation.quick, value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

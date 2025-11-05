//
//  BeforeAfterSlider.swift
//  HomeDesignAI
//
//  Interactive before/after image comparison slider
//

import SwiftUI

struct BeforeAfterSlider: View {
    let beforeImage: UIImage
    let afterImage: UIImage

    @State private var sliderPosition: CGFloat = 0.5

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Before image (full width)
                Image(uiImage: beforeImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width)

                // After image (clipped by slider position)
                Image(uiImage: afterImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width)
                    .mask(
                        HStack(spacing: 0) {
                            Rectangle()
                                .frame(width: geometry.size.width * sliderPosition)
                            Spacer()
                        }
                    )

                // Slider line
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 3)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                    .offset(x: (geometry.size.width * sliderPosition) - (geometry.size.width / 2))

                // Slider handle
                Circle()
                    .fill(Color.white)
                    .frame(width: 44, height: 44)
                    .shadow(color: .black.opacity(0.2), radius: 4)
                    .overlay(
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 12, weight: .bold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(AppColors.text)
                    )
                    .offset(x: (geometry.size.width * sliderPosition) - (geometry.size.width / 2))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newPosition = (value.location.x / geometry.size.width)
                                sliderPosition = min(max(newPosition, 0), 1)
                            }
                    )

                // Labels
                VStack {
                    HStack {
                        Text("BEFORE")
                            .font(AppFonts.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(4)
                            .padding()

                        Spacer()

                        Text("AFTER")
                            .font(AppFonts.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.goldAccent.opacity(0.9))
                            .cornerRadius(4)
                            .padding()
                    }
                    Spacer()
                }
            }
        }
        .aspectRatio(beforeImage.size.width / beforeImage.size.height, contentMode: .fit)
    }
}

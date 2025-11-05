//
//  EmailBottomSheet.swift
//  HomeDesignAI
//
//  Bottom sheet for email capture
//

import SwiftUI

struct EmailBottomSheet: View {
    @Binding var isPresented: Bool
    @Binding var email: String
    @Binding var isSubscribed: Bool
    let onSubmit: () -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    // Drag handle
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                        .padding(.bottom, 20)

                    // Content
                    VStack(spacing: 16) {
                        Text("Want 10 More Designs?")
                            .font(AppFonts.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.text)

                        Text("Enter your email to unlock 10 additional AI-generated Christmas designs")
                            .font(AppFonts.callout)
                            .foregroundColor(AppColors.text.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        // Email input
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("your@email.com", text: $email)
                                .textFieldStyle(PlainTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(AppCornerRadius.md)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                        .stroke(AppColors.goldAccent.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, AppSpacing.xl)

                        // Submit button
                        Button(action: {
                            onSubmit()
                            withAnimation(.spring()) {
                                isPresented = false
                            }
                        }) {
                            Text("Get 10 More Designs")
                                .font(AppFonts.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.goldAccent)
                                .cornerRadius(AppCornerRadius.md)
                        }
                        .padding(.horizontal, AppSpacing.xl)
                        .disabled(email.isEmpty)
                        .opacity(email.isEmpty ? 0.5 : 1.0)

                        // Dismiss button
                        Button(action: {
                            withAnimation(.spring()) {
                                isPresented = false
                            }
                        }) {
                            Text("Maybe Later")
                                .font(AppFonts.callout)
                                .foregroundColor(AppColors.text.opacity(0.6))
                        }
                        .padding(.bottom, AppSpacing.md)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xl)
                }
                .frame(maxWidth: .infinity)
                .background(AppColors.background)
                .cornerRadius(AppCornerRadius.xl, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: -5)
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 100 {
                                withAnimation(.spring()) {
                                    isPresented = false
                                }
                            }
                            withAnimation(.spring()) {
                                dragOffset = 0
                            }
                        }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Color.black.opacity(isPresented ? 0.3 : 0)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
}

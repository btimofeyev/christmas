//
//  Extensions.swift
//  HomeDesignAI
//
//  Useful extensions for the app
//

import SwiftUI

// MARK: - Color Extensions

extension Color {
    /// Initialize Color from hex string
    /// - Parameter hex: Hex color string (e.g., "#FAFAFA" or "FAFAFA")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extensions

extension View {
    /// Applies a card style with shadow and rounded corners
    func cardStyle() -> some View {
        self
            .background(AppColors.cardBackground)
            .cornerRadius(AppCornerRadius.md)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    /// Hides keyboard when tapping outside
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// Applies if condition
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Apple-style button press animation (2025 micro-interaction)
    func pressAnimation() -> some View {
        self.buttonStyle(PressableButtonStyle())
    }

    /// Applies corner radius to specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Button Styles (2025 Apple Design)

/// Modern button style with spring-based press animation
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(AppAnimation.buttonPress, value: configuration.isPressed)
    }
}

// MARK: - String Extensions

extension String {
    /// Checks if string is not empty (trimmed)
    var isNotEmpty: Bool {
        !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Image Extensions

extension Image {
    /// Creates an Image from base64 data URL string
    /// - Parameter base64String: Base64 data URL
    /// - Returns: Image if conversion successful
    static func fromBase64(_ base64String: String) -> Image? {
        guard let uiImage = ImageProcessor.shared.convertFromBase64(base64String) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}

// MARK: - UIApplication Extensions

extension UIApplication {
    /// Opens URL in Safari
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        open(url)
    }
}

// MARK: - Haptic Feedback (2025 Apple Design)

/// Haptic feedback helper following Apple's design guidelines
enum HapticFeedback {
    /// Light impact feedback (button taps)
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium impact feedback (selections, toggles)
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy impact feedback (important actions)
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    /// Success notification (completion)
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning notification (alerts)
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error notification (failures)
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    /// Selection feedback (picker changes)
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

extension View {
    /// Adds haptic feedback on tap
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                let generator = UIImpactFeedbackGenerator(style: style)
                generator.impactOccurred()
            }
        )
    }
}

// MARK: - Shapes

/// Custom shape for rounding specific corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

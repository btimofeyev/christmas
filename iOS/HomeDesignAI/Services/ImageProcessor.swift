//
//  ImageProcessor.swift
//  HomeDesignAI
//
//  Handles image compression, resizing, and base64 conversion
//

import Foundation
import UIKit

class ImageProcessor {
    static let shared = ImageProcessor()

    // Maximum dimension for uploaded images (as per PRD)
    private let maxDimension: CGFloat = 2048

    private init() {}

    // MARK: - Image Compression & Resizing

    /// Compresses and resizes image to ≤2048px while maintaining aspect ratio
    /// - Parameter image: Original UIImage
    /// - Returns: Compressed UIImage
    func compressImage(_ image: UIImage) -> UIImage? {
        // Calculate new size
        let size = image.size
        let maxDim = max(size.width, size.height)

        if maxDim <= maxDimension {
            // Already within limits, just compress quality
            return compressQuality(image)
        }

        // Calculate scale factor
        let scale = maxDimension / maxDim
        let newSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )

        // Resize image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        image.draw(in: CGRect(origin: .zero, size: newSize))
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        return compressQuality(resizedImage)
    }

    /// Compresses image quality to reduce file size
    private func compressQuality(_ image: UIImage, quality: CGFloat = 0.8) -> UIImage? {
        guard let data = image.jpegData(compressionQuality: quality),
              let compressedImage = UIImage(data: data) else {
            return nil
        }
        return compressedImage
    }

    // MARK: - Base64 Conversion

    /// Converts UIImage to base64 data URL string
    /// - Parameter image: UIImage to convert
    /// - Returns: Base64 data URL string (e.g., "data:image/jpeg;base64,...")
    func convertToBase64(image: UIImage) -> String? {
        // Compress first
        guard let compressed = compressImage(image) else {
            return nil
        }

        // Convert to JPEG data
        guard let imageData = compressed.jpegData(compressionQuality: 0.8) else {
            return nil
        }

        // Convert to base64
        let base64String = imageData.base64EncodedString()
        return "data:image/jpeg;base64,\(base64String)"
    }

    /// Converts base64 data URL string to UIImage
    /// - Parameter base64String: Base64 data URL (e.g., "data:image/jpeg;base64,...")
    /// - Returns: UIImage if conversion successful
    func convertFromBase64(_ base64String: String) -> UIImage? {
        // Remove data URL prefix if present
        let base64 = base64String
            .replacingOccurrences(of: "data:image/jpeg;base64,", with: "")
            .replacingOccurrences(of: "data:image/png;base64,", with: "")

        // Convert to Data
        guard let imageData = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
            return nil
        }

        // Convert to UIImage
        return UIImage(data: imageData)
    }

    // MARK: - Image Utilities

    /// Gets the estimated file size of an image in MB
    func getImageSize(_ image: UIImage) -> Double {
        guard let data = image.jpegData(compressionQuality: 1.0) else {
            return 0
        }
        return Double(data.count) / 1_048_576 // Convert bytes to MB
    }

    /// Checks if image needs compression
    func needsCompression(_ image: UIImage) -> Bool {
        let size = image.size
        let maxDim = max(size.width, size.height)
        return maxDim > maxDimension || getImageSize(image) > 5.0 // > 5MB
    }
}

//
//  VideoExporter.swift
//  HomeDesignAI
//
//  Creates shareable before/after transition videos for social media
//

import Foundation
import UIKit
import AVFoundation
import CoreImage

enum VideoExportError: Error {
    case missingImages
    case creationFailed(String)
    case exportFailed(String)

    var localizedDescription: String {
        switch self {
        case .missingImages:
            return "Before and after images are required"
        case .creationFailed(let message):
            return "Failed to create video: \(message)"
        case .exportFailed(let message):
            return "Failed to export video: \(message)"
        }
    }
}

class VideoExporter {
    static let shared = VideoExporter()

    private init() {}

    /// Creates an animated before/after transition video optimized for Instagram Stories
    /// - Parameters:
    ///   - beforeImage: Original room photo
    ///   - afterImage: AI-decorated photo
    ///   - completion: Returns URL to the exported video file
    func createBeforeAfterVideo(
        beforeImage: UIImage,
        afterImage: UIImage,
        completion: @escaping (Result<URL, VideoExportError>) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Instagram Stories optimal size: 1080x1920 (9:16)
                let videoSize = CGSize(width: 1080, height: 1920)

                // Resize and fit images to Instagram format
                guard let resizedBefore = self.resizeAndFitImage(beforeImage, to: videoSize),
                      let resizedAfter = self.resizeAndFitImage(afterImage, to: videoSize) else {
                    completion(.failure(.creationFailed("Failed to resize images")))
                    return
                }

                // Add watermark to after image
                let watermarkedAfter = self.addWatermark(to: resizedAfter, videoSize: videoSize)

                // Create video
                let videoURL = try self.generateVideo(
                    beforeImage: resizedBefore,
                    afterImage: watermarkedAfter,
                    videoSize: videoSize
                )

                DispatchQueue.main.async {
                    completion(.success(videoURL))
                }

            } catch let error as VideoExportError {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.exportFailed(error.localizedDescription)))
                }
            }
        }
    }

    // MARK: - Private Helpers

    private func resizeAndFitImage(_ image: UIImage, to targetSize: CGSize) -> UIImage? {
        // Calculate aspect-fit size
        let imageAspect = image.size.width / image.size.height
        let targetAspect = targetSize.width / targetSize.height

        var drawRect = CGRect(origin: .zero, size: targetSize)

        if imageAspect > targetAspect {
            // Image is wider - fit to width
            let scaledHeight = targetSize.width / imageAspect
            let yOffset = (targetSize.height - scaledHeight) / 2
            drawRect = CGRect(x: 0, y: yOffset, width: targetSize.width, height: scaledHeight)
        } else {
            // Image is taller - fit to height
            let scaledWidth = targetSize.height * imageAspect
            let xOffset = (targetSize.width - scaledWidth) / 2
            drawRect = CGRect(x: xOffset, y: 0, width: scaledWidth, height: targetSize.height)
        }

        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        // Fill background with subtle gradient
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(white: 0.95, alpha: 1.0).cgColor, UIColor.white.cgColor]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: colors as CFArray,
                                  locations: [0.0, 1.0])!
        context?.drawLinearGradient(gradient,
                                   start: CGPoint(x: 0, y: 0),
                                   end: CGPoint(x: 0, y: targetSize.height),
                                   options: [])

        // Draw image
        image.draw(in: drawRect)

        return UIGraphicsGetImageFromCurrentImageContext()
    }

    private func addWatermark(to image: UIImage, videoSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(videoSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }

        // Draw original image
        image.draw(at: .zero)

        // Add watermark text
        let watermarkText = "Made with HomeDesign AI 🎄"
        let downloadText = "HomeDesignAI.app"

        let watermarkAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 48, weight: .bold),
            .foregroundColor: UIColor.white,
            .shadow: {
                let shadow = NSShadow()
                shadow.shadowColor = UIColor.black.withAlphaComponent(0.8)
                shadow.shadowBlurRadius = 12
                shadow.shadowOffset = CGSize(width: 0, height: 3)
                return shadow
            }()
        ]

        let downloadAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 36, weight: .semibold),
            .foregroundColor: UIColor.white,
            .shadow: {
                let shadow = NSShadow()
                shadow.shadowColor = UIColor.black.withAlphaComponent(0.7)
                shadow.shadowBlurRadius = 8
                shadow.shadowOffset = CGSize(width: 0, height: 2)
                return shadow
            }()
        ]

        // Calculate positions (bottom center)
        let watermarkSize = (watermarkText as NSString).size(withAttributes: watermarkAttributes)
        let downloadSize = (downloadText as NSString).size(withAttributes: downloadAttributes)

        let watermarkX = (videoSize.width - watermarkSize.width) / 2
        let watermarkY = videoSize.height - watermarkSize.height - downloadSize.height - 100

        let downloadX = (videoSize.width - downloadSize.width) / 2
        let downloadY = videoSize.height - downloadSize.height - 60

        // Draw watermark
        (watermarkText as NSString).draw(at: CGPoint(x: watermarkX, y: watermarkY), withAttributes: watermarkAttributes)
        (downloadText as NSString).draw(at: CGPoint(x: downloadX, y: downloadY), withAttributes: downloadAttributes)

        return UIGraphicsGetImageFromCurrentImageContext() ?? image
    }

    private func generateVideo(
        beforeImage: UIImage,
        afterImage: UIImage,
        videoSize: CGSize
    ) throws -> URL {
        // Video settings
        let fps: Int32 = 30
        let duration: Double = 4.0  // 4 seconds total (1s before, 2s transition, 1s after)
        let totalFrames = Int(duration * Double(fps))

        // Output URL
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")

        // Remove if exists
        try? FileManager.default.removeItem(at: outputURL)

        // Create asset writer
        guard let videoWriter = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
            throw VideoExportError.creationFailed("Failed to create video writer")
        }

        // Video settings
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoSize.width,
            AVVideoHeightKey: videoSize.height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 6_000_000,  // 6 Mbps for high quality
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
        ]

        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
                kCVPixelBufferWidthKey as String: videoSize.width,
                kCVPixelBufferHeightKey as String: videoSize.height
            ]
        )

        videoWriter.add(writerInput)

        // Start writing
        guard videoWriter.startWriting() else {
            throw VideoExportError.exportFailed("Failed to start writing")
        }

        videoWriter.startSession(atSourceTime: .zero)

        // Generate frames
        let frameQueue = DispatchQueue(label: "com.homedesignai.framequeue")
        var frameIndex = 0

        let semaphore = DispatchSemaphore(value: 0)

        writerInput.requestMediaDataWhenReady(on: frameQueue) {
            while writerInput.isReadyForMoreMediaData && frameIndex < totalFrames {
                let presentationTime = CMTime(value: Int64(frameIndex), timescale: fps)
                let progress = Double(frameIndex) / Double(totalFrames)

                // Calculate opacity based on timing
                // 0-0.25: Show before (opacity = 0)
                // 0.25-0.75: Transition (opacity 0 -> 1)
                // 0.75-1.0: Show after (opacity = 1)
                var afterOpacity: CGFloat = 0

                if progress < 0.25 {
                    afterOpacity = 0
                } else if progress < 0.75 {
                    let transitionProgress = (progress - 0.25) / 0.5
                    // Smooth ease-in-out
                    afterOpacity = CGFloat(self.easeInOutCubic(transitionProgress))
                } else {
                    afterOpacity = 1.0
                }

                // Create blended frame
                if let pixelBuffer = self.createBlendedFrame(
                    beforeImage: beforeImage,
                    afterImage: afterImage,
                    afterOpacity: afterOpacity,
                    size: videoSize
                ) {
                    adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                }

                frameIndex += 1
            }

            if frameIndex >= totalFrames {
                writerInput.markAsFinished()
                videoWriter.finishWriting {
                    semaphore.signal()
                }
            }
        }

        // Wait for completion
        semaphore.wait()

        if videoWriter.status == .completed {
            return outputURL
        } else {
            throw VideoExportError.exportFailed(videoWriter.error?.localizedDescription ?? "Unknown error")
        }
    }

    private func createBlendedFrame(
        beforeImage: UIImage,
        afterImage: UIImage,
        afterOpacity: CGFloat,
        size: CGSize
    ) -> CVPixelBuffer? {
        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]

        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            options as CFDictionary,
            &pixelBuffer
        )

        guard let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )

        guard let ctx = context else { return nil }

        // Draw before image
        if let beforeCG = beforeImage.cgImage {
            ctx.draw(beforeCG, in: CGRect(origin: .zero, size: size))
        }

        // Draw after image with opacity
        if afterOpacity > 0, let afterCG = afterImage.cgImage {
            ctx.setAlpha(afterOpacity)
            ctx.draw(afterCG, in: CGRect(origin: .zero, size: size))
        }

        return buffer
    }

    // Smooth easing function for transition
    private func easeInOutCubic(_ t: Double) -> Double {
        return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
    }
}

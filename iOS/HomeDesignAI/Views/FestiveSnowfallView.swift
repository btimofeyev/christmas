//
//  FestiveSnowfallView.swift
//  HomeDesignAI
//
//  Shared festive snowfall overlay.
//

import SwiftUI

struct FestiveSnowfallView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let snowflakes = Snowflake.generate(count: 42)

    var body: some View {
        GeometryReader { geometry in
            Group {
                if reduceMotion {
                    staticSnowField(in: geometry.size)
                } else {
                    animatedSnowfall(in: geometry.size)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func staticSnowField(in size: CGSize) -> some View {
        ZStack {
            ForEach(snowflakes) { flake in
                Circle()
                    .fill(flake.color.opacity(0.6))
                    .frame(width: flake.size, height: flake.size)
                    .position(flake.startingPosition(in: size))
            }
        }
    }

    @ViewBuilder
    private func animatedSnowfall(in size: CGSize) -> some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                ForEach(snowflakes) { flake in
                    Circle()
                        .fill(flake.color)
                        .frame(width: flake.size, height: flake.size)
                        .position(flake.position(at: time, in: size))
                        .opacity(flake.opacity(at: time))
                        .blur(radius: flake.blurRadius, opaque: false)
                }
            }
        }
    }
}

private struct Snowflake: Identifiable {
    let id = UUID()
    let normalizedX: CGFloat
    let initialProgress: Double
    let size: CGFloat
    let duration: Double
    let wobbleDistance: CGFloat
    let wobbleSpeed: Double
    let phase: Double
    let color: Color
    let opacityRange: ClosedRange<Double>
    let blurRadius: CGFloat

    func position(at time: TimeInterval, in size: CGSize) -> CGPoint {
        let fallCycles = (time / duration) + initialProgress
        let progress = fallCycles.truncatingRemainder(dividingBy: 1.0)

        let totalHeight = size.height + CGFloat(160)
        let yPosition = (CGFloat(progress) * totalHeight) - CGFloat(80)

        let baseX = normalizedX * size.width
        let drift = CGFloat(sin((time * wobbleSpeed) + phase)) * wobbleDistance
        let rawX = baseX + drift

        let wrappedX = rawX.truncatingRemainder(dividingBy: size.width)
        let correctedX = wrappedX < 0 ? wrappedX + size.width : wrappedX

        return CGPoint(x: correctedX, y: yPosition)
    }

    func startingPosition(in size: CGSize) -> CGPoint {
        let totalHeight = size.height + CGFloat(160)
        let yPosition = (CGFloat(initialProgress) * totalHeight) - CGFloat(80)
        let xPosition = normalizedX * size.width
        return CGPoint(x: xPosition, y: yPosition)
    }

    func opacity(at time: TimeInterval) -> Double {
        let wave = (sin((time * 0.9) + phase) + 1) / 2
        return opacityRange.lowerBound + (opacityRange.upperBound - opacityRange.lowerBound) * wave
    }

    static func generate(count: Int) -> [Snowflake] {
        let palette: [Color] = [
            Color.white.opacity(0.9),
            Color.white.opacity(0.65),
            AppColors.surface.opacity(0.4),
            AppColors.accent.opacity(0.55)
        ]

        return (0..<count).map { _ in
            Snowflake(
                normalizedX: CGFloat.random(in: 0...1),
                initialProgress: Double.random(in: 0...1),
                size: CGFloat.random(in: 4...10),
                duration: Double.random(in: 9...18),
                wobbleDistance: CGFloat.random(in: 8...26),
                wobbleSpeed: Double.random(in: 0.6...1.4),
                phase: Double.random(in: 0...(2 * .pi)),
                color: palette.randomElement() ?? Color.white.opacity(0.8),
                opacityRange: 0.25...0.8,
                blurRadius: CGFloat.random(in: 0...1.2)
            )
        }
    }
}

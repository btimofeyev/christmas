//
//  DecorStyle.swift
//  HomeDesignAI
//
//  Christmas decoration style presets
//

import Foundation
import SwiftUI

enum DecorStyle: String, Codable, CaseIterable {
    case classicChristmas = "classic_christmas"
    case nordicMinimalist = "nordic_minimalist"
    case modernSilver = "modern_silver"
    case cozyFamily = "cozy_family"
    case rusticFarmhouse = "rustic_farmhouse"
    case elegantGold = "elegant_gold"
    case custom

    var displayName: String {
        switch self {
        case .classicChristmas:
            return "Classic Christmas"
        case .nordicMinimalist:
            return "Nordic Minimalist"
        case .modernSilver:
            return "Modern Silver"
        case .cozyFamily:
            return "Cozy Family"
        case .rusticFarmhouse:
            return "Rustic Farmhouse"
        case .elegantGold:
            return "Elegant Gold"
        case .custom:
            return "Custom Style"
        }
    }

    var description: String {
        switch self {
        case .classicChristmas:
            return "Rich red and gold accents with traditional garland, tree, and stockings"
        case .nordicMinimalist:
            return "White, pine, and natural woods — clean and modern"
        case .modernSilver:
            return "White and metallic tones, elegant and sleek"
        case .cozyFamily:
            return "Warm lighting, rustic decorations, soft textures"
        case .rusticFarmhouse:
            return "Country charm with burlap, wood, and vintage lanterns"
        case .elegantGold:
            return "Luxurious gold and cream tones, sophisticated and refined"
        case .custom:
            return "Describe your own unique style"
        }
    }

    var icon: String {
        switch self {
        case .classicChristmas:
            return "gift.fill"
        case .nordicMinimalist:
            return "snowflake"
        case .modernSilver:
            return "star.fill"
        case .cozyFamily:
            return "heart.fill"
        case .rusticFarmhouse:
            return "house.fill"
        case .elegantGold:
            return "crown.fill"
        case .custom:
            return "wand.and.stars"
        }
    }

    var accentColor: Color {
        switch self {
        case .classicChristmas:
            return Color(red: 0.8, green: 0.1, blue: 0.1) // Deep red
        case .nordicMinimalist:
            return Color(red: 0.9, green: 0.9, blue: 0.9) // Off-white
        case .modernSilver:
            return Color(red: 0.75, green: 0.75, blue: 0.75) // Silver
        case .cozyFamily:
            return Color(red: 0.9, green: 0.5, blue: 0.2) // Warm orange
        case .rusticFarmhouse:
            return Color(red: 0.6, green: 0.4, blue: 0.2) // Brown
        case .elegantGold:
            return Color(red: 0.83, green: 0.69, blue: 0.22) // Gold
        case .custom:
            return Color(red: 0.5, green: 0.5, blue: 0.5) // Gray
        }
    }

    // Get all preset styles (excluding custom)
    static var presets: [DecorStyle] {
        return [.classicChristmas, .nordicMinimalist, .modernSilver, .cozyFamily, .rusticFarmhouse, .elegantGold]
    }
}

// MARK: - Decoration Intensity

enum DecorationIntensity: String, Codable, CaseIterable {
    case minimal
    case light
    case medium
    case heavy
    case maximal

    var displayName: String {
        switch self {
        case .minimal:
            return "Minimal"
        case .light:
            return "Light"
        case .medium:
            return "Medium"
        case .heavy:
            return "Heavy"
        case .maximal:
            return "Maximal"
        }
    }

    var description: String {
        switch self {
        case .minimal:
            return "Very sparse, 1-2 focal points"
        case .light:
            return "Tasteful, key areas only"
        case .medium:
            return "Balanced decoration"
        case .heavy:
            return "Generous, abundant decor"
        case .maximal:
            return "Fully decorated, no bare spaces"
        }
    }

    var icon: String {
        switch self {
        case .minimal:
            return "circle"
        case .light:
            return "circle.lefthalf.filled"
        case .medium:
            return "circle.fill"
        case .heavy:
            return "circle.hexagongrid.fill"
        case .maximal:
            return "square.grid.3x3.fill"
        }
    }

    var fillLevel: Double {
        switch self {
        case .minimal:
            return 0.2
        case .light:
            return 0.4
        case .medium:
            return 0.6
        case .heavy:
            return 0.8
        case .maximal:
            return 1.0
        }
    }
}

//
//  SceneType.swift
//  HomeDesignAI
//
//  Scene type selection (Interior or Exterior)
//

import Foundation

enum SceneType: String, Codable, CaseIterable {
    case interior
    case exterior

    var displayName: String {
        switch self {
        case .interior:
            return "Interior"
        case .exterior:
            return "Exterior"
        }
    }

    var icon: String {
        switch self {
        case .interior:
            return "house.fill"
        case .exterior:
            return "building.2.fill"
        }
    }

    var description: String {
        switch self {
        case .interior:
            return "Decorate indoor spaces"
        case .exterior:
            return "Decorate outdoor spaces"
        }
    }
}

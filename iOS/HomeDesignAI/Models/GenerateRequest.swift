//
//  GenerateRequest.swift
//  HomeDesignAI
//
//  API request model for /generate endpoint
//

import Foundation

struct GenerateRequest: Codable {
    let scene: String
    let style: String
    let prompt: String?
    let lighting: String
    let intensity: String
    let imageBase64: String

    enum CodingKeys: String, CodingKey {
        case scene
        case style
        case prompt
        case lighting
        case intensity
        case imageBase64 = "image_base64"
    }

    init(scene: SceneType, style: DecorStyle, prompt: String? = nil, lighting: HomeDesignViewModel.LightingMode, intensity: DecorationIntensity, imageBase64: String) {
        self.scene = scene.rawValue
        self.style = style.rawValue
        self.prompt = prompt
        self.lighting = lighting.rawValue
        self.intensity = intensity.rawValue
        self.imageBase64 = imageBase64
    }
}

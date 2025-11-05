//
//  GenerateResponse.swift
//  HomeDesignAI
//
//  API response model from /generate endpoint
//

import Foundation

struct GenerateResponse: Codable {
    let decoratedImageBase64: String
    let products: [AffiliateProduct]
    let meta: ResponseMeta?
    let note: String?

    enum CodingKeys: String, CodingKey {
        case decoratedImageBase64 = "decorated_image_base64"
        case products
        case meta
        case note
    }
}

struct ResponseMeta: Codable {
    let style: String
    let scene: String
    let timestamp: String
}

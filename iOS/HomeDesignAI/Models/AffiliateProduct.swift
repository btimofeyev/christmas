//
//  AffiliateProduct.swift
//  HomeDesignAI
//
//  Model for affiliate product recommendations
//

import Foundation

struct AffiliateProduct: Codable, Identifiable {
    let name: String
    let price: String
    let image: String
    let link: String
    let asin: String?
    let rating: Double?
    let reviewCount: Int?
    let priceRange: String?
    let tags: [String]?

    var id: String { asin ?? name }

    enum CodingKeys: String, CodingKey {
        case name
        case price
        case image
        case link
        case asin
        case rating
        case reviewCount
        case priceRange
        case tags
    }
}

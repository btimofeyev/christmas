//
//  APIService.swift
//  HomeDesignAI
//
//  Handles all API communication with the Node.js backend
//

import Foundation
import UIKit

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(String, generationsRemaining: Int? = nil, totalGenerated: Int? = nil)

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid server URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let message, _, _):
            return "Server error: \(message)"
        }
    }

    var generationsRemaining: Int? {
        switch self {
        case .serverError(_, let remaining, _):
            return remaining
        default:
            return nil
        }
    }

    var totalGenerated: Int? {
        switch self {
        case .serverError(_, _, let total):
            return total
        default:
            return nil
        }
    }
}

class APIService {
    static let shared = APIService()

    // MARK: - Configuration
    private var baseURL: String {
        #if DEBUG
        return "http://localhost:3000"
        #else
        return "https://holidayhomeai.up.railway.app"
        #endif
    }

    private init() {}

    // MARK: - Generate Decorated Image

    /// Generates a Christmas-decorated version of the uploaded image
    /// - Parameters:
    ///   - image: The original UIImage to decorate
    ///   - scene: Interior or exterior scene type
    ///   - style: Decoration style preset
    ///   - customPrompt: Optional custom prompt (required if style is .custom)
    ///   - lighting: Day or night lighting mode
    ///   - intensity: Decoration intensity level
    /// - Returns: GenerateResponse containing decorated image and products
    func generateDecoratedImage(
        image: UIImage,
        scene: SceneType,
        style: DecorStyle,
        customPrompt: String? = nil,
        lighting: HomeDesignViewModel.LightingMode = .day,
        intensity: DecorationIntensity = .medium
    ) async throws -> GenerateResponse {

        // Convert image to base64
        guard let imageBase64 = ImageProcessor.shared.convertToBase64(image: image) else {
            throw APIError.invalidResponse
        }

        // Get device ID for tracking
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString

        // Build request
        let request = GenerateRequest(
            scene: scene,
            style: style,
            prompt: customPrompt,
            lighting: lighting,
            intensity: intensity,
            imageBase64: imageBase64,
            deviceId: deviceId
        )

        // Make API call
        guard let url = URL(string: "\(baseURL)/generate") else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 120 // 2 minutes timeout for AI generation

        do {
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(request)
        } catch {
            throw APIError.decodingError(error)
        }

        // Perform request
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            // Check for server errors
            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(
                        errorResponse.message ?? "Unknown error",
                        generationsRemaining: errorResponse.generationsRemaining,
                        totalGenerated: errorResponse.totalGenerated
                    )
                }
                throw APIError.serverError("HTTP \(httpResponse.statusCode)")
            }

            // Decode response
            let decoder = JSONDecoder()
            let generateResponse = try decoder.decode(GenerateResponse.self, from: data)
            return generateResponse

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Health Check

    /// Checks if the backend server is running
    func healthCheck() async throws -> Bool {
        guard let url = URL(string: "\(baseURL)/health") else {
            throw APIError.invalidURL
        }

        let (_, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            return false
        }

        return httpResponse.statusCode == 200
    }

    // MARK: - Referral System

    /// Generates a unique referral code for the current user
    /// - Parameter deviceId: Unique device identifier
    /// - Returns: ReferralCodeResponse containing the code and shareable URL
    func generateReferralCode(deviceId: String) async throws -> ReferralCodeResponse {
        guard let url = URL(string: "\(baseURL)/referral/generate-referral") else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 30

        let requestBody = ["deviceId": deviceId]

        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw APIError.decodingError(error)
        }

        // Perform request
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.error)
                }
                throw APIError.serverError("HTTP \(httpResponse.statusCode)")
            }

            let decoder = JSONDecoder()
            let referralResponse = try decoder.decode(ReferralCodeResponse.self, from: data)
            return referralResponse

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    /// Claims a referral code (called when new user installs via referral link)
    /// - Parameters:
    ///   - code: The referral code to claim
    ///   - deviceId: Unique device identifier of the claimer
    /// - Returns: ReferralClaimResponse with reward information
    func claimReferral(code: String, deviceId: String) async throws -> ReferralClaimResponse {
        guard let url = URL(string: "\(baseURL)/referral/claim-referral") else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 30

        let requestBody = [
            "code": code,
            "claimerDeviceId": deviceId
        ]

        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw APIError.decodingError(error)
        }

        // Perform request
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            // Handle error responses (400, 404, etc.)
            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.error)
                }
                throw APIError.serverError("HTTP \(httpResponse.statusCode)")
            }

            let decoder = JSONDecoder()
            let claimResponse = try decoder.decode(ReferralClaimResponse.self, from: data)
            return claimResponse

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    /// Gets or creates user and returns current generation counts
    /// - Parameter deviceId: Unique device identifier
    /// - Returns: UserDataResponse with current generation counts
    func getOrCreateUser(deviceId: String) async throws -> UserDataResponse {
        guard let url = URL(string: "\(baseURL)/referral/user/\(deviceId)") else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.timeoutInterval = 30

        // Perform request
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            if httpResponse.statusCode != 200 {
                if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.error)
                }
                throw APIError.serverError("HTTP \(httpResponse.statusCode)")
            }

            let decoder = JSONDecoder()
            let userDataResponse = try decoder.decode(UserDataResponse.self, from: data)
            return userDataResponse

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Helper Models

private struct ErrorResponse: Codable {
    let error: String
    let message: String?
    let details: [String]?
    let generationsRemaining: Int?
    let totalGenerated: Int?
}

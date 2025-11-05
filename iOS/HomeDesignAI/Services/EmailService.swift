//
//  EmailService.swift
//  HomeDesignAI
//
//  Handles email subscription for main app beta access
//

import Foundation

enum EmailError: Error {
    case invalidEmail
    case networkError(Error)
    case serverError(String)

    var localizedDescription: String {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let message):
            return message
        }
    }
}

struct SubscribeResponse: Codable {
    let success: Bool
    let message: String
    let alreadySubscribed: Bool?
}

class EmailService {
    static let shared = EmailService()

    private var baseURL: String {
        #if DEBUG
        return "http://localhost:3000"
        #else
        return "https://your-backend-url.com" // Update with production URL
        #endif
    }

    private init() {}

    /// Subscribe user to main app beta access list
    /// - Parameter email: User's email address
    /// - Returns: Success message and whether already subscribed
    func subscribe(email: String) async throws -> (message: String, alreadySubscribed: Bool) {
        // Basic email validation
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard isValidEmail(trimmedEmail) else {
            throw EmailError.invalidEmail
        }

        // Build request
        guard let url = URL(string: "\(baseURL)/subscribe") else {
            throw EmailError.serverError("Invalid server URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let body = [
            "email": trimmedEmail,
            "source": "christmas_app"
        ]

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw EmailError.networkError(error)
        }

        // Perform request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw EmailError.serverError("Invalid response from server")
            }

            // Decode response
            let decoder = JSONDecoder()
            let subscribeResponse = try decoder.decode(SubscribeResponse.self, from: data)

            if subscribeResponse.success {
                return (subscribeResponse.message, subscribeResponse.alreadySubscribed ?? false)
            } else {
                throw EmailError.serverError(subscribeResponse.message)
            }

        } catch let error as EmailError {
            throw error
        } catch {
            throw EmailError.networkError(error)
        }
    }

    /// Validates email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

import Foundation

// MARK: - Login Request
struct LoginRequest: Encodable {
    let username: String
    let phone_number: String
    let pin: String
}

// MARK: - Login Response
struct LoginResponse: Decodable {
    let message: String
    let token: String?
    let user: User?
}

// MARK: - User Model
struct User: Decodable {
    let id: Int
    let username: String
    let phone_number: String
    // Add other fields if necessary
}

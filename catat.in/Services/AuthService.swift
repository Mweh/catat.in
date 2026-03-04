import Foundation

class AuthService {
    
    enum AuthError: Error, LocalizedError {
        case invalidURL
        case invalidResponse
        case invalidData
        case custom(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Terjadi kesalahan pada URL server."
            case .invalidResponse: return "Respons server tidak valid."
            case .invalidData: return "Data yang diterima rusak atau tidak sesuai."
            case .custom(let message): return message
            }
        }
    }
    
    static let shared = AuthService()
    
    private init() {}
    
    func login(request: LoginRequest) async throws -> LoginResponse {
        guard let url = URL(string: "\(Config.baseURL)/users/login") else {
            throw AuthError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            urlRequest.httpBody = try encoder.encode(request)
        } catch {
            throw AuthError.invalidData
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        // Log response for debugging
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Login Response (\(httpResponse.statusCode)): \(jsonString)")
        }
        
        let decoder = JSONDecoder()
        
        if (200...299).contains(httpResponse.statusCode) {
            do {
                let loginResponse = try decoder.decode(LoginResponse.self, from: data)
                return loginResponse
            } catch {
                throw AuthError.invalidData
            }
        } else {
            // Try to parse error message if any
            struct ErrorResponse: Decodable {
                let error: String?
                let message: String?
            }
            if let errorMsg = try? decoder.decode(ErrorResponse.self, from: data) {
                let message = errorMsg.message ?? errorMsg.error ?? "Login gagal (Kode: \(httpResponse.statusCode))"
                throw AuthError.custom(message)
            } else {
                throw AuthError.custom("Login gagal (Kode: \(httpResponse.statusCode))")
            }
        }
    }
}

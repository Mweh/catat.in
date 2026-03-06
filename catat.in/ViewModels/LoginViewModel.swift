import Foundation
import SwiftUI
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var phoneNumber: String = ""
    @Published var pin: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showErrorMessage: Bool = false
    
    func login(completion: @escaping (Bool) -> Void) {
        guard !username.isEmpty, !phoneNumber.isEmpty, !pin.isEmpty else {
            self.errorMessage = "Mohon isi semua data"
            self.showErrorMessage = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        showErrorMessage = false
        
        let request = LoginRequest(username: username, phone_number: phoneNumber, pin: pin)
        
        Task {
            do {
                let response = try await AuthService.shared.login(request: request)
                
                // Save token tracking if it exists
                if let token = response.token {
                    UserDefaults.standard.set(token, forKey: "authToken")
                }
                
                // Save user ID if needed
                if let userId = response.user?.id {
                    UserDefaults.standard.set(userId, forKey: "userId")
                }
                
                // Success
                isLoading = false
                completion(true)
            } catch {
                isLoading = false
                self.errorMessage = error.localizedDescription
                self.showErrorMessage = true
                completion(false)
            }
        }
    }
}

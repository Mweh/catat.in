import Foundation
import Combine

/// Stores and retrieves the user's display name locally via UserDefaults.
class UserProfileService: ObservableObject {
    private let nameKey = "catatin_username"

    @Published var username: String {
        didSet {
            UserDefaults.standard.set(username, forKey: nameKey)
        }
    }

    static let shared = UserProfileService()

    private init() {
        username = UserDefaults.standard.string(forKey: "catatin_username") ?? "Pengguna"
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 5..<12:
            return "Selamat pagi,"
        case 12..<15:
            return "Selamat siang,"
        case 15..<19:
            return "Selamat sore,"
        default:
            return "Selamat malam,"
        }
    }}

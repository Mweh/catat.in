import Foundation

struct Expense: Identifiable, Codable {
    var id: UUID = UUID()
    var amount: Double
    var merchant: String
    var category: String
    var date: Date
}

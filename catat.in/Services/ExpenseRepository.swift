import Combine
import Foundation

class ExpenseRepository: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var monthlyLimit: Double = 3800000 // default as seen in mock
    
    init() {
        loadExpenses()
        loadLimit()
    }
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        saveExpenses()
    }
    
    func setLimit(_ limit: Double) {
        monthlyLimit = limit
        UserDefaults.standard.set(limit, forKey: "catatin_monthly_limit")
    }
    
    func getTotalForCurrentMonth() -> Double {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        return expenses.filter {
            calendar.component(.month, from: $0.date) == currentMonth &&
            calendar.component(.year, from: $0.date) == currentYear
        }.reduce(0) { $0 + $1.amount }
    }

    /// Retrieve grouped breakdown for the charts
    func getCategoryBreakdown() -> [String: Double] {
        var breakdown: [String: Double] = [:]
        for exp in expenses {
            breakdown[exp.category, default: 0] += exp.amount
        }
        return breakdown
    }
    
    private let storageKey = "catatin_saved_expenses"
    
    func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadLimit() {
        let savedLimit = UserDefaults.standard.double(forKey: "catatin_monthly_limit")
        if savedLimit > 0 {
            self.monthlyLimit = savedLimit
        }
    }
    
    private func loadExpenses() {
        if let savedData = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Expense].self, from: savedData) {
            self.expenses = decoded
        } else {
            // Seed with mock data for preview and empty-state avoidance
            self.expenses = [
                Expense(amount: 125000, merchant: "Indomaret", category: "Makanan", date: Date()),
                Expense(amount: 45000, merchant: "Grab", category: "Transportasi", date: Date()),
                Expense(amount: 300000, merchant: "Supermarket", category: "Belanja", date: Date())
            ]
        }
    }
}

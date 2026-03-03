import AppIntents

// MARK: - Intent: Query Monthly Spending via Siri
struct GetMonthlySpendingIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Monthly Spending"
    static var description = IntentDescription(
        "Ask catat.in how much you spent this month.",
        categoryName: "Expense Tracking"
    )

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let repo = AppIntentDependencyProvider.shared.expenseRepository
        let total = repo.getTotalForCurrentMonth()

        let spokenResponse: String
        if total == 0 {
            spokenResponse = "Belum ada pengeluaran yang tercatat bulan ini."
        } else {
            let formatted = SiriCurrencyFormatter.spoken(total)
            spokenResponse = "Bulan ini kamu sudah menghabiskan \(formatted)."
        }

        return .result(dialog: IntentDialog(stringLiteral: spokenResponse))
    }
}

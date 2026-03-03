import Foundation

// MARK: - Currency Formatter for Siri Responses
// Used by App Intents for spoken currency values.
// Note: FormattedCurrency in ContentView.swift is used for UI display.
// This formatter is dedicated to the Intents layer to keep it self-contained.
enum SiriCurrencyFormatter {

    /// Returns "Rp 1.250.000" format for Siri spoken output
    static func spoken(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        formatter.currencySymbol = "Rp "
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "Rp 0"
    }
}

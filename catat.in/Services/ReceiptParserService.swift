import Foundation

struct ReceiptData {
    var merchant: String
    var totalAmount: Double
    var items: [String] = []
}

class ReceiptParserService {
    /// Extracts structured ReceiptData from raw text
    func parse(text: String) -> ReceiptData {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // 1. Merchant Detection: Assume top line is generally the merchant name
        var merchant = "Unknown Merchant"
        if let firstLine = lines.first, 
           !firstLine.lowercased().contains("kuitansi") && !firstLine.lowercased().contains("receipt") {
            merchant = firstLine
        }
        
        // 2. Total Amount Detection
        var totalAmount: Double = 0.0
        let totalKeywords = ["total", "jumlah", "grand total", "amount due", "tagihan"]
        
        for (index, line) in lines.enumerated() {
            let lowercased = line.lowercased()
            
            if totalKeywords.contains(where: { lowercased.contains($0) }) {
                // Check if amount is inline
                if let amount = extractAmount(from: line) {
                    totalAmount = amount
                    break
                } 
                // Alternatively, check the next line
                else if index + 1 < lines.count, let amount = extractAmount(from: lines[index + 1]) {
                    totalAmount = amount
                    break
                }
            }
        }
        
        // 3. Fallback: Identify the largest currency value parsed
        if totalAmount == 0.0 {
            var maxAmount = 0.0
            for line in lines {
                if let amount = extractAmount(from: line), amount > maxAmount {
                    maxAmount = amount
                }
            }
            totalAmount = maxAmount
        }

        return ReceiptData(merchant: merchant, totalAmount: totalAmount)
    }
    
    /// Parses textual amount by removing typical currency formats like 'Rp' and period separators
    private func extractAmount(from text: String) -> Double? {
        let cleaned = text.replacingOccurrences(of: "Rp", with: "", options: .caseInsensitive)
                          .replacingOccurrences(of: " ", with: "")
                          .replacingOccurrences(of: ".", with: "") // Indonesian thousands separator
                          .replacingOccurrences(of: ",", with: ".") // Indonesian decimal separator
                          
        let pattern = "[0-9]+(?:\\.[0-9]{1,2})?"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let matches = regex.matches(in: cleaned, range: NSRange(cleaned.startIndex..., in: cleaned))
            if let lastMatch = matches.last, let range = Range(lastMatch.range, in: cleaned) {
                return Double(String(cleaned[range]))
            }
        }
        return nil
    }
}

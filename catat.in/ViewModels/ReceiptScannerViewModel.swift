import Foundation
import UIKit
import Combine

enum ScanningState {
    case idle
    case scanning
    case processing
    case success(ReceiptData)
    case failed(String)
}

@MainActor
class ReceiptScannerViewModel: ObservableObject {
    @Published var state: ScanningState = .idle
    @Published var parsedData: ReceiptData?
    
    private let scannerService = ReceiptScannerService()
    private let parserService = ReceiptParserService()
    
    func processImage(_ image: UIImage) {
        self.state = .processing
        
        Task {
            do {
                let text = try await scannerService.scanReceipt(from: image)
                let data = parserService.parse(text: text)
                self.parsedData = data
                self.state = .success(data)
            } catch {
                self.state = .failed("Gagal membaca teks struk. Coba foto baru dengan pencahayaan yang pas.")
            }
        }
    }
    
    func reset() {
        state = .idle
        parsedData = nil
    }
}

import Foundation
import Vision
import UIKit

class ReceiptScannerService {
    enum ScannerError: Error {
        case invalidImage
        case processingFailed
    }

    /// Processes an uploaded or captured image to extract recognized text
    func scanReceipt(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw ScannerError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                
                // Extract top candidate from each recognized observation
                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }
                
                // Join all recognized lines
                let resultText = recognizedStrings.joined(separator: "\n")
                continuation.resume(returning: resultText)
            }
            
            // Optimize for accuracy
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

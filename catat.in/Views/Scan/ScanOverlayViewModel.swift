import Foundation
import Combine

class ScanOverlayViewModel: ObservableObject {
    @Published var state: ScanHUDState = .idle
    @Published var instructionText: String = "Posisikan struk di dalam frame"

    func transition(to newState: ScanHUDState) {
        DispatchQueue.main.async {
            self.state = newState
            self.instructionText = self.label(for: newState)
        }
    }

    private func label(for state: ScanHUDState) -> String {
        switch state {
        case .idle:       return "Posisikan struk di dalam frame"
        case .scanning:   return "Mendeteksi struk..."
        case .detecting:  return "Memproses..."
        case .success:    return "Struk berhasil dipindai ✓"
        case .failed:     return "Gagal membaca struk. Coba lagi."
        }
    }
}

import AppIntents
import AVFoundation

// MARK: - Intent: Open Scan Screen via Siri
struct ScanReceiptIntent: AppIntent {
    static var title: LocalizedStringResource = "Scan Receipt"
    static var description = IntentDescription(
        "Open catat.in camera scanner to scan a receipt.",
        categoryName: "Expense Tracking"
    )

    // Opens the app when this intent is performed
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Check camera permission first
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .denied, .restricted:
            return .result(
                dialog: "Kamera tidak diizinkan. Buka Pengaturan dan aktifkan akses kamera untuk catat.in."
            )
        default:
            break
        }

        // Post notification — MainView listens and opens ScanReceiptView
        await MainActor.run {
            NotificationCenter.default.post(name: .openScanScreen, object: nil)
        }

        return .result(dialog: "Membuka scanner struk catat.in...")
    }
}

// MARK: - Shared Notification Name
extension Notification.Name {
    static let openScanScreen = Notification.Name("catat.in.openScanScreen")
}

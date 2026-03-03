import Foundation

enum ScanHUDState: Equatable {
    case idle
    case scanning
    case detecting
    case success
    case failed
}

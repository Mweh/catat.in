import Foundation

// MARK: - Dependency Provider for App Intents
// Intent layer accesses data exclusively through this provider.
// Never access UserDefaults or storage directly from an intent.
final class AppIntentDependencyProvider {
    static let shared = AppIntentDependencyProvider()

    /// Shared ExpenseRepository — loads from UserDefaults so it always
    /// reflects the latest data even when app is not in foreground.
    private(set) lazy var expenseRepository: ExpenseRepository = {
        ExpenseRepository()
    }()

    private init() {}
}

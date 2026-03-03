import AppIntents

// MARK: - Shortcuts Provider
// Registers all Siri phrases. This runs automatically when the app is first launched.
struct CatatInShortcuts: AppShortcutsProvider {

    static var appShortcuts: [AppShortcut] {

        // ── Epic 1: Scan Receipt ───────────────────────────────────────────
        AppShortcut(
            intent: ScanReceiptIntent(),
            phrases: [
                "Scan my receipt in \(.applicationName)",
                "Scan struk di \(.applicationName)",
                "Open scanner in \(.applicationName)",
                "Scan pengeluaran di \(.applicationName)"
            ],
            shortTitle: "Scan Struk",
            systemImageName: "camera.viewfinder"
        )

        // ── Epic 2: Monthly Spending ───────────────────────────────────────
        AppShortcut(
            intent: GetMonthlySpendingIntent(),
            phrases: [
                "How much did I spend this month in \(.applicationName)",
                "Berapa pengeluaranku bulan ini di \(.applicationName)",
                "Monthly spending in \(.applicationName)",
                "Cek pengeluaran bulan ini di \(.applicationName)"
            ],
            shortTitle: "Pengeluaran Bulan Ini",
            systemImageName: "chart.pie.fill"
        )
    }
}

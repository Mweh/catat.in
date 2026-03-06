import SwiftUI

struct FormattedCurrency {
    static func format(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        formatter.currencySymbol = "Rp "
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "Rp 0"
    }
}

struct ContentView: View {
    @State private var hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @StateObject private var repo = ExpenseRepository()
    
    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                    .onChange(of: hasSeenOnboarding) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "hasSeenOnboarding")
                    }
            } else if !isLoggedIn {
                LoginView()
            } else {
                MainView()
                    .environmentObject(repo)
            }
        }
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentStep = 0
    
    var body: some View {
        VStack {
            // Top Nav
            HStack {
                Spacer()
                if currentStep < 2 {
                    Button(action: {
                        withAnimation { hasSeenOnboarding = true }
                    }) {
                    }
                    .padding()
                } else {
                    Text(" ").padding()
                }
            }
            
            TabView(selection: $currentStep) {
                OnboardingStepContent(
                    imageName: "doc.viewfinder.fill",
                    title: "Selamat datang di catat.in",
                    subtitle: "Scan cepat, hidup hemat.",
                    description: "Kelola pengeluaran harian dengan mudah hanya lewat satu kali scan struk."
                ).tag(0)
                
                OnboardingStepContent(
                    imageName: "camera.viewfinder",
                    title: "Scan struk dalam hitungan detik",
                    subtitle: nil,
                    description: "Arahkan kamera ke struk, dan biarkan catat.in membaca serta mencatat otomatis."
                ).tag(1)
                
                OnboardingStepContent(
                    imageName: "chart.pie.fill",
                    title: "Laporan otomatis dan rapi",
                    subtitle: nil,
                    description: "Semua pengeluaran langsung dikelompokkan dan siap dilihat dalam dashboard."
                ).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(index == currentStep ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: index == currentStep ? 10 : 8, height: index == currentStep ? 10 : 8)
                        .animation(.spring(), value: currentStep)
                }
            }
            .padding(.bottom, 32)
            
            VStack(spacing: 16) {
                Button(action: {
                    withAnimation {
                        if currentStep < 2 {
                            currentStep += 1
                        } else {
                            hasSeenOnboarding = true
                        }
                    }
                }) {
                    Text(currentStep == 0 ? "Mulai" : (currentStep == 1 ? "Lanjut" : "Masuk ke Dashboard"))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(16)
                }
                
                if currentStep == 0 {
                    Button(action: {
                        withAnimation { hasSeenOnboarding = true }
                    }) {
                        Text("Lewati")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                } else {
                    Text(" ").font(.system(size: 16, weight: .semibold))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.white)
    }
}

struct OnboardingStepContent: View {
    let imageName: String
    let title: String
    let subtitle: String?
    let description: String
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 200, height: 200)
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
            }
            .padding(.bottom, 32)
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.green)
                }
                
                Text(description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Main View
struct MainView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var repo: ExpenseRepository
    
    @State private var showScan = false
    @State private var showLimit = false
    @State private var showLaporan = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                Color(white: 0.98).ignoresSafeArea()
                
                switch selectedTab {
                case 0: 
                    DashboardView(
                        onScanTapped: { showScan = true },
                        onSetLimitTapped: { showLimit = true },
                        onLaporanTapped: { showLaporan = true }
                    )
                case 1:
                    Text("Limit Placeholder").foregroundColor(.gray)
                case 3:
                    Text("Laporan Placeholder").foregroundColor(.gray)
                case 4:
                    ProfileSettingsView()
                default: 
                    DashboardView(
                        onScanTapped: { showScan = true },
                        onSetLimitTapped: { showLimit = true },
                        onLaporanTapped: { showLaporan = true }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar matching Image 1
            HStack(spacing: 0) {
                TabBarItem(iconName: "house.fill", title: "Beranda", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                TabBarItem(iconName: "target", title: "Limit", isSelected: selectedTab == 1) {
                    showLimit = true
                }
                
                Spacer()
                
                Button(action: { showScan = true }) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 56, height: 56)
                                .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .offset(y: -15)
                    }
                }
                
                Spacer()
                
                TabBarItem(iconName: "chart.pie.fill", title: "Laporan", isSelected: selectedTab == 3) {
                    showLaporan = true
                }
                
                TabBarItem(iconName: "gearshape.fill", title: "Setting", isSelected: selectedTab == 4) {
                    selectedTab = 4
                }
            }
            .padding(.top, 10)
            .background(
                Color.white
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                    .ignoresSafeArea(.all, edges: .bottom)
            )
        }
        .fullScreenCover(isPresented: $showScan) {
            ScanReceiptView(
                onDismiss: {
                    showScan = false
                }
            )
        }
        .fullScreenCover(isPresented: $showLimit) {
            SetMonthlyLimitView()
        }
        .fullScreenCover(isPresented: $showLaporan) {
            LaporanView()
        }
        // ── Siri / App Intents deep-link ──────────────────────────────────
        // ScanReceiptIntent posts this notification → opens scan screen directly
        .onReceive(NotificationCenter.default.publisher(for: .openScanScreen)) { _ in
            showScan = true
        }
    }
}

struct TabBarItem: View {
    let iconName: String
    let title: String
    var isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .frame(height: 24)
                Text(title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(isSelected ? .green : .gray)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}

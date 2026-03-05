import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var repo: ExpenseRepository
    @StateObject private var profile = UserProfileService.shared

    var onScanTapped: () -> Void
    var onSetLimitTapped: (() -> Void)?
    var onLaporanTapped: (() -> Void)?

    // Sheet states
    @State private var showEditUsername = false
    @State private var draftName = ""
    @State private var showAddCategory = false
    @State private var showManualEntry = false

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 24, pinnedViews: []) {

                    // ── 1. Header ──────────────────────────────────────────
                    HStack(spacing: 14) {
                        Button(action: {
                            draftName = profile.username
                            showEditUsername = true
                        }) {
                            Image(systemName: "text.alignleft")
                                .font(.system(size: 20))
                                .foregroundColor(.orange)
                                .frame(width: 48, height: 48)
                                .background(Color.orange.opacity(0.15))
                                .clipShape(Circle())
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(profile.greeting)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Text("Halo, \(profile.username)!")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // ── 2. Summary Card ────────────────────────────────────
                    summaryCard
                        .padding(.horizontal, 20)

                    // ── 3. Category Grid ───────────────────────────────────
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Kategori Utama")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(red: 0.05, green: 0.1, blue: 0.2))
                            Spacer()
                        }
                        .padding(.horizontal, 20)

                        let breakdown = repo.getCategoryBreakdown()

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(repo.allCategories) { cat in
                                CategoryCard(
                                    icon: cat.icon,
                                    title: cat.name,
                                    amount: FormattedCurrency.format(breakdown[cat.name] ?? 0),
                                    bgColor: cat.colorName.categoryColor.opacity(0.12),
                                    iconColor: cat.colorName.categoryColor
                                )
                            }

                            Button(action: { showAddCategory = true }) {
                                VStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.green.opacity(0.12))
                                            .frame(width: 48, height: 48)
                                        Image(systemName: "plus")
                                            .foregroundColor(.green)
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                    Text("Tambah\nKategori")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 130)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.green.opacity(0.4),
                                                style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                                )
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .sheet(isPresented: $showAddCategory) {
                        AddCategorySheet().environmentObject(repo)
                    }

                    // ── 4. Recent Activity ─────────────────────────────────
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Aktivitas Terakhir")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.05, green: 0.1, blue: 0.2))
                            .padding(.horizontal, 20)

                        if repo.expenses.isEmpty {
                            Text("Belum ada aktivitas")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(repo.expenses.sorted(by: { $0.date > $1.date })) { expense in
                                    let iconName: String = {
                                        switch expense.category {
                                        case "Makanan":      return "fork.knife"
                                        case "Belanja":      return "bag.fill"
                                        case "Transportasi": return "car.fill"
                                        default:             return "creditcard.fill"
                                        }
                                    }()
                                    let catColor: Color = {
                                        switch expense.category {
                                        case "Makanan":      return .orange
                                        case "Belanja":      return .purple
                                        case "Transportasi": return .blue
                                        default:             return .gray
                                        }
                                    }()

                                    RecentActivityRow(
                                        icon: iconName,
                                        iconBgColor: catColor.opacity(0.15),
                                        iconColor: catColor,
                                        title: expense.merchant,
                                        subtitle: expense.category,
                                        amount: "- \(FormattedCurrency.format(expense.amount))",
                                        amountColor: .red
                                    )
                                    .swipeToDelete {
                                        if let idx = repo.expenses.firstIndex(where: { $0.id == expense.id }) {
                                            repo.expenses.remove(at: idx)
                                            repo.saveExpenses()
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }

                    Spacer(minLength: 120)
                }
            }
            .background(Color(white: 0.96).ignoresSafeArea())
            .sheet(isPresented: $showEditUsername) {
                EditUsernameSheet(name: $draftName) {
                    profile.username = draftName
                }
            }
            .sheet(isPresented: $showManualEntry) {
                ManualExpenseSheet().environmentObject(repo)
            }

            // ── Floating pencil button (bottom-left, above tab bar) ────
            Button(action: { showManualEntry = true }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.18, green: 0.75, blue: 0.40),
                                         Color(red: 0.08, green: 0.60, blue: 0.30)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 54, height: 54)
                        .shadow(color: .green.opacity(0.4), radius: 10, x: 0, y: 5)
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.trailing, 24)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Summary Card
    private var summaryCard: some View {
        let total = repo.getTotalForCurrentMonth()
        let limit = repo.monthlyLimit
        let ratio: Double = limit > 0 ? min(total / limit, 1.0) : 0
        let remaining = max(limit - total, 0)

        let gradientColors: [Color] = ratio >= 1.0
            ? [Color(red: 0.85, green: 0.15, blue: 0.1), Color(red: 0.95, green: 0.3, blue: 0.1)]
            : ratio >= 0.8
            ? [Color(red: 0.95, green: 0.5, blue: 0.1), Color(red: 0.98, green: 0.65, blue: 0.2)]
            : [Color(red: 0.95, green: 0.3, blue: 0.1), Color(red: 0.98, green: 0.65, blue: 0.2)]

        return VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Uang Kamu yang Sudah Keluar")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.95))
                    Spacer()
                    Button(action: { onSetLimitTapped?() }) {
                        Text("Set Limit")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.25))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }

                Text("-\(FormattedCurrency.format(total))")
                    .font(.system(size: 38, weight: .heavy))
                    .foregroundColor(.white)

                Text("Sisa Limit \(FormattedCurrency.format(remaining))")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.25))
                            .frame(height: 8)
                        Capsule()
                            .fill(Color.white)
                            .frame(width: geo.size.width * CGFloat(ratio), height: 8)
                    }
                }
                .frame(height: 8)
                .padding(.top, 4)
            }
            .padding(20)
            .background(
                LinearGradient(colors: gradientColors,
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )

            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12))
                    .foregroundColor(ratio >= 1.0 ? .red : .orange)
                Text(ratio >= 1.0
                     ? "Limit terlampaui! Pertimbangkan untuk menaikkan limit."
                     : "Catat terus pengeluaranmu biar gak kaget akhir bulan!")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(ratio >= 1.0 ? .red : Color(red: 0.8, green: 0.4, blue: 0.0))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Edit Username Sheet
struct EditUsernameSheet: View {
    @Binding var name: String
    @Environment(\.dismiss) var dismiss
    var onSave: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                    .padding(.top, 32)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Nama Pengguna")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gray)
                    TextField("Masukkan nama kamu", text: $name)
                        .font(.system(size: 16))
                        .padding(14)
                        .background(Color(white: 0.95))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 24)

                Button(action: {
                    let trimmed = name.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty { name = trimmed; onSave() }
                    dismiss()
                }) {
                    Text("Simpan")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .cornerRadius(20)
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .navigationTitle("Edit Nama")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Swipe to delete modifier
extension View {
    func swipeToDelete(action: @escaping () -> Void) -> some View {
        modifier(SwipeToDeleteModifier(action: action))
    }
}

struct SwipeToDeleteModifier: ViewModifier {
    let action: () -> Void
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            if offset < -20 {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.red)
                    .overlay(
                        Image(systemName: "trash.fill")
                            .foregroundColor(.white)
                            .padding(.trailing, 20),
                        alignment: .trailing
                    )
                    .padding(.horizontal, 20)
            }
            content
                .offset(x: offset)
                .gesture(
                    DragGesture(minimumDistance: 20, coordinateSpace: .local)
                        .onChanged { v in
                            guard v.translation.width < 0 else { return }
                            offset = max(v.translation.width, -80)
                        }
                        .onEnded { _ in
                            if offset < -60 {
                                withAnimation(.easeOut(duration: 0.2)) { offset = -400 }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { action() }
                            } else {
                                withAnimation(.spring()) { offset = 0 }
                            }
                        }
                )
        }
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let icon: String
    let title: String
    let amount: String
    let bgColor: Color
    let iconColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle().fill(bgColor).frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
            Text("-\(amount)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.red.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Recent Activity Row
struct RecentActivityRow: View {
    let icon: String
    let iconBgColor: Color
    let iconColor: Color
    let title: String
    let subtitle: String
    let amount: String
    let amountColor: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(iconBgColor).frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(amount)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(amountColor)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}

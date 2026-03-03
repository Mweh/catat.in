import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var repo: ExpenseRepository
    var onScanTapped: () -> Void
    var onSetLimitTapped: (() -> Void)?
    var onLaporanTapped: (() -> Void)?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Image(systemName: "book.pages.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.orange)
                        .frame(width: 48, height: 48)
                        .background(Color.orange.opacity(0.2))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Selamat pagi,")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text("Halo, Alex!")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                    }
                    Spacer()
                    
                    Button(action: {}) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            Image(systemName: "bell.fill")
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.3))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Card Total Pengeluaran
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Total Pengeluaran")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Button(action: {
                            onSetLimitTapped?()
                        }) {
                            Text("Set Limit")
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                    }
                    
                    Text(FormattedCurrency.format(repo.getTotalForCurrentMonth()))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            let percentage = repo.monthlyLimit > 0 ? (repo.getTotalForCurrentMonth() / repo.monthlyLimit) * 100 : 0
                            Text(String(format: "%.0f%% Terpakai", min(percentage, 100)))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("Limit: \(FormattedCurrency.format(repo.monthlyLimit))")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(height: 12)
                                
                                let total = repo.getTotalForCurrentMonth()
                                let ratio = repo.monthlyLimit > 0 ? min(total / repo.monthlyLimit, 1.0) : 0
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * CGFloat(ratio), height: 12)
                            }
                        }
                        .frame(height: 12)
                        
                        let total2 = repo.getTotalForCurrentMonth()
                        let ratio2 = repo.monthlyLimit > 0 ? total2 / repo.monthlyLimit : 0
                        Text(ratio2 >= 1.0 ? "Anda telah melewati batas limit!" : (ratio2 >= 0.8 ? "Hati-hati, pengeluaran mendekati limit." : "Anda masih dalam zona aman bulan ini."))
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 4)
                    }
                }
                .padding(24)
                .background(
                    Group {
                        let total = repo.getTotalForCurrentMonth()
                        let ratio = repo.monthlyLimit > 0 ? total / repo.monthlyLimit : 0
                        if ratio >= 1.0 {
                            Color.red
                        } else if ratio >= 0.8 {
                            Color.orange
                        } else {
                            LinearGradient(gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        }
                    }
                )
                .cornerRadius(32)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                
                // Kategori Utama
                VStack(spacing: 16) {
                    HStack {
                        Text("Kategori Utama")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.05, green: 0.1, blue: 0.2))
                        Spacer()
                        Button(action: {
                            onLaporanTapped?()
                        }) {
                            Text("Lihat Semua")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 16) {
                        let breakdown = repo.getCategoryBreakdown()
                        
                        CategoryCard(
                            icon: "fork.knife", 
                            title: "Makanan", 
                            amount: FormattedCurrency.format(breakdown["Makanan"] ?? 0), 
                            bgColor: Color.orange.opacity(0.1), 
                            iconColor: .orange
                        )
                        CategoryCard(
                            icon: "car.fill", 
                            title: "Transportasi", 
                            amount: FormattedCurrency.format(breakdown["Transportasi"] ?? 0), 
                            bgColor: Color.blue.opacity(0.1), 
                            iconColor: .blue
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 16) {
                        let breakdown = repo.getCategoryBreakdown()
                        
                        CategoryCard(
                            icon: "bag.fill", 
                            title: "Belanja", 
                            amount: FormattedCurrency.format(breakdown["Belanja"] ?? 0), 
                            bgColor: Color.purple.opacity(0.1), 
                            iconColor: .purple
                        )
                        
                        // Tambah Kategori
                        VStack(alignment: .center, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(width: 48, height: 48)
                                Image(systemName: "plus")
                                    .foregroundColor(.gray)
                            }
                            Text("Tambah Kategori")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 130)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // Aktivitas Terakhir
                VStack(spacing: 16) {
                    HStack {
                        Text("Aktivitas Terakhir")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(red: 0.05, green: 0.1, blue: 0.2))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    if repo.expenses.isEmpty {
                        Text("Belum ada aktivitas")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(repo.expenses.sorted(by: { $0.date > $1.date }).prefix(5)) { expense in
                                let iconName: String = {
                                    switch expense.category {
                                    case "Makanan": return "fork.knife"
                                    case "Belanja": return "bag.fill"
                                    case "Transportasi": return "car.fill"
                                    default: return "creditcard.fill"
                                    }
                                }()
                                let catColor: Color = {
                                    switch expense.category {
                                    case "Makanan": return .orange
                                    case "Belanja": return .purple
                                    case "Transportasi": return .blue
                                    default: return .gray
                                    }
                                }()
                                
                                RecentActivityRow(
                                    icon: iconName, 
                                    iconBgColor: catColor.opacity(0.15), 
                                    iconColor: catColor, 
                                    title: expense.merchant, 
                                    subtitle: "Hari ini", 
                                    amount: "- \(FormattedCurrency.format(expense.amount))", 
                                    amountColor: .red
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer(minLength: 120) // Tab bar clearance
            }
        }
        .background(Color(white: 0.96).ignoresSafeArea())
    }
}

struct CategoryCard: View {
    let icon: String
    let title: String
    let amount: String
    let bgColor: Color
    let iconColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(bgColor)
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            .padding(.bottom, 4)
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
            Text(amount)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(24)
    }
}

struct RecentActivityRow: View {
    let icon: String
    let iconBgColor: Color
    let iconColor: Color
    let title: String
    let subtitle: String
    let amount: String
    let amountColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconBgColor)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
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
        .padding(16)
        .background(Color.white)
        .cornerRadius(24)
    }
}

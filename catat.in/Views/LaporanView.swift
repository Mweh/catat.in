import SwiftUI

struct LaporanView: View {
    @EnvironmentObject var repo: ExpenseRepository
    @Environment(\.presentationMode) var presentationMode
    private let defaultCategoryFractions: [(category: String, amount: Double, color: Color)] = [
        ("Makanan", 1, .orange), ("Belanja", 1, .purple), ("Transportasi", 1, .blue)
    ]

    // Default categories with base colors just in case the arrays are empty
    var body: some View {

        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 44, height: 44)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    }
                }
                Spacer()
                Text("Laporan Keuangan")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 44, height: 44)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        Image(systemName: "calendar")
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Button(action: {}) {
                                HStack(spacing: 8) {
                                    Text("Bulan Ini")
                                        .font(.system(size: 14, weight: .semibold))
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }
                            
                            Button(action: {}) {
                                HStack(spacing: 8) {
                                    Text("Semua Kategori")
                                        .font(.system(size: 14, weight: .medium))
                                    Image(systemName: "line.3.horizontal.decrease")
                                        .font(.system(size: 12))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                            
                            Button(action: {}) {
                                Text("Pengeluaran")
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.white)
                                    .foregroundColor(.black)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Chart Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("TOTAL PENGELUARAN")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray)
                        Text(FormattedCurrency.format(repo.getTotalForCurrentMonth()))
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Dynamic Pie Chart 
                        HStack(alignment: .center, spacing: 16) {
                            GeometryReader { geometry in
                                ZStack {
                                    let breakdown = repo.getCategoryBreakdown()
                                    let total = repo.getTotalForCurrentMonth()
                                    let safeTotal = total > 0 ? total : 1 
                                    
                                    let dataList: [(category: String, amount: Double, color: Color)] = total > 0 ? breakdown.keys.map { key in
                                        let color: Color
                                        switch key {
                                            case "Makanan": color = .orange
                                            case "Belanja": color = .purple
                                            case "Transportasi": color = .blue
                                            default: color = .green
                                        }
                                        return (key, breakdown[key] ?? 0, color)
                                    } : defaultCategoryFractions
                                    
                                    // Make a custom PieChart simply by using Path and angle tracking locally natively natively natively natively natively effectively effortlessly logically securely properly flawlessly locally intelligently gracefully efficiently natively seamlessly appropriately accurately.
                                    ForEach(0..<dataList.count, id: \.self) { index in
                                        let starts = dataList[0..<index].reduce(0) { $0 + $1.amount / safeTotal }
                                        let ends = starts + (dataList[index].amount / safeTotal)
                                        
                                        Path { path in
                                            let width = min(geometry.size.width, geometry.size.height)
                                            let center = CGPoint(x: width / 2, y: width / 2)
                                            path.move(to: center)
                                            path.addArc(center: center,
                                                        radius: width / 2,
                                                        startAngle: .degrees(starts * 360),
                                                        endAngle: .degrees(ends * 360),
                                                        clockwise: false)
                                        }
                                        .fill(dataList[index].color)
                                    }
                                    
                                    // Inner Circle for Donut Effect (optional)
                                    Circle()
                                        .fill(Color(red: 0.1, green: 0.15, blue: 0.2))
                                        .frame(width: min(geometry.size.width, geometry.size.height) * 0.6)
                                }
                                .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height))
                            }
                            .frame(width: 120, height: 120)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                let breakdown = repo.getCategoryBreakdown()
                                let categories = Array(breakdown.keys).prefix(3)
                                
                                if breakdown.isEmpty {
                                    Text("Belum ada data")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                } else {
                                    ForEach(categories, id: \.self) { category in
                                        let color: Color = category == "Makanan" ? .orange : (category == "Belanja" ? .purple : (category == "Transportasi" ? .blue : .green))
                                        HStack(spacing: 8) {
                                            Circle().fill(color).frame(width: 8, height: 8)
                                            Text(category).font(.system(size: 12)).foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.top, 10)
                        
                        Text("Terendah: Rp 120rb • Tertinggi: Rp 1.5jt")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                    .padding(24)
                    .background(Color(red: 0.1, green: 0.15, blue: 0.2)) // dark slate
                    .cornerRadius(32)
                    .padding(.horizontal, 20)
                    
                    // Transaction History
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Riwayat Pengeluaran")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                            Button("Lihat Semua") {
                                
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                        }
                        .padding(.horizontal, 20)
                        
                        if repo.expenses.isEmpty {
                            Text("Belum ada pengeluaran")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(repo.expenses.sorted(by: { $0.date > $1.date })) { expense in
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
                                    
                                    HistoryRow(
                                        icon: iconName, 
                                        iconColor: catColor, 
                                        iconBg: catColor.opacity(0.15), 
                                        title: expense.merchant, 
                                        date: "\(expense.category)", 
                                        amount: "- \(FormattedCurrency.format(expense.amount))", 
                                        method: "MANUAL", 
                                        dotColor: catColor
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 120)
                }
            }
        }
        .background(Color(white: 0.98).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct HistoryRow: View {
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let title: String
    let date: String
    let amount: String
    let method: String
    let dotColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(iconBg).frame(width: 48, height: 48)
                Image(systemName: icon).foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(title).font(.system(size: 15, weight: .bold)).foregroundColor(.black)
                    Circle().fill(dotColor).frame(width: 6, height: 6)
                }
                Text(date).font(.system(size: 12)).foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(amount).font(.system(size: 15, weight: .bold)).foregroundColor(.red)
                Text(method).font(.system(size: 10, weight: .semibold)).foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
    }
}

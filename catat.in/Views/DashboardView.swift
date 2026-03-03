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
                            .foregroundColor(.gray)
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
                    
                    Text("Rp 2.450.000")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(red: 0.05, green: 0.1, blue: 0.2))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("65% Terpakai")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.green)
                            Spacer()
                            Text("Limit: Rp 3.800.000")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(height: 12)
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.green)
                                    .frame(width: geometry.size.width * 0.65, height: 12)
                            }
                        }
                        .frame(height: 12)
                        
                        Text("Anda masih dalam zona aman bulan ini.")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(32)
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
                        CategoryCard(icon: "fork.knife", title: "Makanan", amount: "Rp 850.000", bgColor: Color.orange.opacity(0.1), iconColor: .orange)
                        CategoryCard(icon: "car.fill", title: "Transport", amount: "Rp 420.000", bgColor: Color.blue.opacity(0.1), iconColor: .blue)
                    }
                    .padding(.horizontal, 20)
                    
                    HStack(spacing: 16) {
                        CategoryCard(icon: "ticket.fill", title: "Entertain", amount: "Rp 310.000", bgColor: Color.purple.opacity(0.1), iconColor: .purple)
                        
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
                    
                    VStack(spacing: 12) {
                        RecentActivityRow(
                            icon: "bag.fill", 
                            iconBgColor: Color.green.opacity(0.15), 
                            iconColor: .green, 
                            title: "Belanja Bulanan", 
                            subtitle: "Hari ini, 14:20", 
                            amount: "- Rp 120.000", 
                            amountColor: .red
                        )
                        
                        RecentActivityRow(
                            icon: "banknote.fill", 
                            iconBgColor: Color.green.opacity(0.15), 
                            iconColor: .green, 
                            title: "Gaji Masuk", 
                            subtitle: "Kemarin, 09:00", 
                            amount: "+ Rp 5.000.000", 
                            amountColor: .green
                        )
                    }
                    .padding(.horizontal, 20)
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

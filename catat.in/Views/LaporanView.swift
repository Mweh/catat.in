import SwiftUI

struct LaporanView: View {
    @Environment(\.presentationMode) var presentationMode
    
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
                        Text("Rp 4.250.000")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Fake Bar Chart
                        HStack(alignment: .bottom, spacing: 8) {
                            RoundedRectangle(cornerRadius: 4).fill(Color.green.opacity(0.6)).frame(height: 30)
                            RoundedRectangle(cornerRadius: 4).fill(Color.green.opacity(0.6)).frame(height: 45)
                            RoundedRectangle(cornerRadius: 4).fill(Color.green.opacity(0.6)).frame(height: 25)
                            RoundedRectangle(cornerRadius: 4).fill(Color.green.opacity(0.8)).frame(height: 60)
                            RoundedRectangle(cornerRadius: 4).fill(Color.green).frame(height: 80) // highest
                            RoundedRectangle(cornerRadius: 4).fill(Color.green.opacity(0.8)).frame(height: 40)
                            RoundedRectangle(cornerRadius: 4).fill(Color.green.opacity(0.6)).frame(height: 35)
                        }
                        .frame(height: 90)
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
                        
                        VStack(spacing: 12) {
                            HistoryRow(icon: "fork.knife", iconColor: .orange, iconBg: Color.orange.opacity(0.15), title: "Makan Siang", date: "14 Okt 2023 • Food & Drinks", amount: "-Rp 85.000", method: "DEBIT CARD", dotColor: .orange)
                            HistoryRow(icon: "car.fill", iconColor: .blue, iconBg: Color.blue.opacity(0.15), title: "Bensin Pertamax", date: "13 Okt 2023 • Transport", amount: "-Rp 150.000", method: "CASH", dotColor: .blue)
                            HistoryRow(icon: "bag.fill", iconColor: .purple, iconBg: Color.purple.opacity(0.15), title: "Belanja Bulanan", date: "12 Okt 2023 • Lifestyle", amount: "-Rp 1.250.000", method: "E-WALLET", dotColor: .purple)
                            HistoryRow(icon: "play.tv.fill", iconColor: .green, iconBg: Color.green.opacity(0.15), title: "Netflix Premium", date: "10 Okt 2023 • Entertainment", amount: "-Rp 186.000", method: "SUBSCRIPTION", dotColor: .green)
                            HistoryRow(icon: "cross.case.fill", iconColor: .yellow, iconBg: Color.yellow.opacity(0.2), title: "Vitamin & Obat", date: "09 Okt 2023 • Health", amount: "-Rp 245.000", method: "CASH", dotColor: .yellow)
                        }
                        .padding(.horizontal, 20)
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

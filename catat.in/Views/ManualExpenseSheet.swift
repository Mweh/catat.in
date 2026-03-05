import SwiftUI

struct ManualExpenseSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var repo: ExpenseRepository

    @State private var amountText: String = ""
    @State private var merchant: String = ""
    @State private var selectedCategory: String = "Makanan"
    @State private var date: Date = Date()
    @State private var showDatePicker = false

    @FocusState private var amountFocused: Bool

    private var parsedAmount: Double {
        Double(amountText.filter { $0.isNumber }) ?? 0
    }

    private var isValid: Bool {
        parsedAmount > 0 && !merchant.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // ── Amount ────────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 10) {
                        fieldLabel("Jumlah Pengeluaran")
                        HStack(spacing: 10) {
                            Text("Rp")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.gray)
                            TextField("0", text: $amountText)
                                .font(.system(size: 28, weight: .bold))
                                .keyboardType(.numberPad)
                                .focused($amountFocused)
                                .onChange(of: amountText) { v in
                                    amountText = v.filter { $0.isNumber }
                                }
                        }
                        .padding(16)
                        .background(Color(white: 0.96))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(amountFocused ? Color.green : .clear, lineWidth: 1.5)
                        )
                    }

                    // ── Merchant ──────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 10) {
                        fieldLabel("Nama Toko / Keterangan")
                        TextField("Contoh: Indomaret, Grab, dll.", text: $merchant)
                            .padding(16)
                            .background(Color(white: 0.96))
                            .cornerRadius(14)
                    }

                    // ── Category chips ────────────────────────────────────
                    VStack(alignment: .leading, spacing: 10) {
                        fieldLabel("Kategori")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(repo.allCategories) { cat in
                                    let isSelected = selectedCategory == cat.name
                                    Button {
                                        withAnimation(.spring(response: 0.25)) {
                                            selectedCategory = cat.name
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: cat.icon)
                                                .font(.system(size: 13))
                                            Text(cat.name)
                                                .font(.system(size: 13, weight: .semibold))
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .foregroundColor(isSelected ? .white : .primary)
                                        .background(isSelected
                                                    ? cat.colorName.categoryColor
                                                    : Color(white: 0.93))
                                        .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal, 1)
                        }
                    }

                    // ── Date ──────────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 10) {
                        fieldLabel("Tanggal")
                        Button {
                            withAnimation { showDatePicker.toggle() }
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.green)
                                Text(date.formatted(date: .long, time: .omitted))
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            .background(Color(white: 0.96))
                            .cornerRadius(14)
                        }

                        if showDatePicker {
                            DatePicker("", selection: $date, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(.green)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }

                    // ── Save ──────────────────────────────────────────────
                    Button(action: save) {
                        Label("Simpan Pengeluaran", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isValid ? Color.green : Color.gray.opacity(0.4))
                            .cornerRadius(20)
                    }
                    .disabled(!isValid)
                }
                .padding(20)
            }
            .navigationTitle("Catat Manual")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
            }
            .onAppear { amountFocused = true }
        }
    }

    private func save() {
        let expense = Expense(
            amount: parsedAmount,
            merchant: merchant.trimmingCharacters(in: .whitespaces),
            category: selectedCategory,
            date: date
        )
        repo.addExpense(expense)
        dismiss()
    }

    @ViewBuilder
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.gray)
    }
}

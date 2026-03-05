import SwiftUI

struct AddCategorySheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var repo: ExpenseRepository

    @State private var name: String = ""
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedColor: CategoryColor = .green
    @FocusState private var nameFocused: Bool

    private let icons = [
        "fork.knife", "cart.fill", "car.fill", "bag.fill", "house.fill",
        "cross.fill", "gamecontroller.fill", "books.vertical.fill",
        "airplane", "tram.fill", "music.note", "cup.and.saucer.fill",
        "dumbbell.fill", "pawprint.fill", "bandage.fill", "tv.fill",
        "phone.fill", "laptopcomputer", "gift.fill", "creditcard.fill"
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {

                    // Preview card
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(selectedColor.swiftUIColor.color.opacity(0.15))
                                .frame(width: 64, height: 64)
                            Image(systemName: selectedIcon)
                                .font(.system(size: 26))
                                .foregroundColor(selectedColor.swiftUIColor.color)
                        }
                        Text(name.isEmpty ? "Nama Kategori" : name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(name.isEmpty ? .gray : .primary)
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color(white: 0.96))
                    .cornerRadius(16)

                    // Name input
                    VStack(alignment: .leading, spacing: 8) {
                        label("Nama Kategori")
                        TextField("Contoh: Hiburan, Kesehatan...", text: $name)
                            .focused($nameFocused)
                            .padding(14)
                            .background(Color(white: 0.96))
                            .cornerRadius(12)
                    }

                    // Icon picker
                    VStack(alignment: .leading, spacing: 12) {
                        label("Ikon")
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(icons, id: \.self) { icon in
                                Button {
                                    withAnimation(.spring(response: 0.25)) {
                                        selectedIcon = icon
                                    }
                                } label: {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedIcon == icon
                                                  ? selectedColor.swiftUIColor.color.opacity(0.2)
                                                  : Color(white: 0.95))
                                        Image(systemName: icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(selectedIcon == icon
                                                             ? selectedColor.swiftUIColor.color
                                                             : .gray)
                                    }
                                    .frame(height: 52)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedIcon == icon
                                                    ? selectedColor.swiftUIColor.color
                                                    : .clear, lineWidth: 2)
                                    )
                                }
                            }
                        }
                    }

                    // Color picker
                    VStack(alignment: .leading, spacing: 12) {
                        label("Warna")
                        HStack(spacing: 12) {
                            ForEach(CategoryColor.allCases, id: \.self) { c in
                                Button {
                                    withAnimation(.spring(response: 0.2)) {
                                        selectedColor = c
                                    }
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(c.swiftUIColor.color)
                                            .frame(width: 34, height: 34)
                                        if selectedColor == c {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }
                    }

                    // Save button
                    Button {
                        saveCategory()
                    } label: {
                        Text("Simpan Kategori")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(name.trimmingCharacters(in: .whitespaces).isEmpty
                                        ? Color.gray.opacity(0.4)
                                        : Color.green)
                            .cornerRadius(20)
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(20)
            }
            .navigationTitle("Tambah Kategori")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }
                }
            }
            .onAppear { nameFocused = true }
        }
    }

    private func saveCategory() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let newCat = CustomCategory(name: trimmed, icon: selectedIcon, colorName: selectedColor.rawValue)
        repo.addCustomCategory(newCat)
        dismiss()
    }

    @ViewBuilder
    private func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.gray)
    }
}

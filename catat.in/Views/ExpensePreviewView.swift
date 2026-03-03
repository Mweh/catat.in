import SwiftUI

struct ExpensePreviewView: View {
    @State var merchant: String
    @State var amount: String
    @State var category: String = "Makanan"
    
    var onSave: (Expense) -> Void
    var onCancel: () -> Void
    
    let categories = ["Makanan", "Transportasi", "Belanja", "Lainnya"]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Konfirmasi Pengeluaran")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Merchant (Otomatis)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("Nama Merchant", text: $merchant)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading) {
                    Text("Total (Otomatis)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("Total", text: $amount)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading) {
                    Text("Kategori")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Picker("Kategori", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8)
            
            HStack(spacing: 16) {
                Button(action: onCancel) {
                    Text("Batal")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.gray)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    let expenseAmount = Double(amount.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: "")) ?? 0
                    let expense = Expense(amount: expenseAmount, merchant: merchant, category: category, date: Date())
                    onSave(expense)
                }) {
                    Text("Simpan Data")
                        .font(.system(size: 16, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(12)
                }
            }
            Spacer()
        }
        .padding(24)
        .background(Color(white: 0.98).edgesIgnoringSafeArea(.all))
    }
}

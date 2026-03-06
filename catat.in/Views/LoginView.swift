import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Header
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.green)
                        .offset(x: -4)
                }
                .padding(.bottom, 16)
                
                Text("Login catat.in")
                    .font(.system(size: 28, weight: .bold))
                
                Text("Silakan masuk untuk melanjutkan")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 32)
            
            // Input Fields
            VStack(spacing: 16) {
                // Username
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                        .frame(width: 24)
                    TextField("Username", text: $viewModel.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Phone Number
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.gray)
                        .frame(width: 24)
                    TextField("Nomor Telepon", text: $viewModel.phoneNumber)
                        .keyboardType(.numberPad)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // PIN
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.gray)
                        .frame(width: 24)
                    SecureField("PIN (6 digit)", text: $viewModel.pin)
                        .keyboardType(.numberPad)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            
            // Error Message
            if viewModel.showErrorMessage {
                Text(viewModel.errorMessage ?? "Terjadi kesalahan")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            
            // Login Button
            Button(action: {
                viewModel.login { success in
                    if success {
                        withAnimation {
                            isLoggedIn = true
                        }
                    }
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 8)
                    }
                    
                    Text(viewModel.isLoading ? "Memproses..." : "Masuk")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    viewModel.username.isEmpty || viewModel.phoneNumber.isEmpty || viewModel.pin.isEmpty
                    ? Color.gray
                    : Color.green
                )
                .cornerRadius(16)
            }
            .disabled(viewModel.isLoading || viewModel.username.isEmpty || viewModel.phoneNumber.isEmpty || viewModel.pin.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .alert(isPresented: $viewModel.showErrorMessage) {
            Alert(
                title: Text("Login Gagal"),
                message: Text(viewModel.errorMessage ?? "Silakan periksa kembali data Anda."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    LoginView()
}

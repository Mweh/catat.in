import SwiftUI

struct ProfileSettingsView: View {
    @StateObject private var profile = UserProfileService.shared
    @State private var draftName: String = ""
    @State private var isEditing = false
    @FocusState private var fieldFocused: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {

                // ── Avatar header ──────────────────────────────────────────
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [.orange.opacity(0.8), .orange],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 88, height: 88)
                        Text(profile.username.prefix(1).uppercased())
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)

                    Text(profile.username)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)

                    Text("Pengguna catat.in")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity)
                .background(Color(white: 0.97))

                // ── Edit Username Card ──────────────────────────────────────
                VStack(alignment: .leading, spacing: 20) {

                    sectionHeader("Profil")

                    VStack(spacing: 0) {
                        // Name row
                        HStack(spacing: 14) {
                            Image(systemName: "person.fill")
                                .frame(width: 32)
                                .foregroundColor(.orange)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Nama")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.gray)

                                if isEditing {
                                    TextField("Nama kamu", text: $draftName)
                                        .font(.system(size: 15))
                                        .focused($fieldFocused)
                                        .submitLabel(.done)
                                        .onSubmit { saveName() }
                                } else {
                                    Text(profile.username)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                }
                            }

                            Spacer()

                            Button(action: {
                                if isEditing {
                                    saveName()
                                } else {
                                    draftName = profile.username
                                    isEditing = true
                                    fieldFocused = true
                                }
                            }) {
                                Text(isEditing ? "Simpan" : "Edit")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(isEditing ? Color.green : Color.orange)
                                    .cornerRadius(12)
                                    .animation(.easeInOut(duration: 0.2), value: isEditing)
                            }
                        }
                        .padding(16)

                        Divider().padding(.leading, 62)

                        // Greeting preview row
                        HStack(spacing: 14) {
                            Image(systemName: "hand.wave.fill")
                                .frame(width: 32)
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Salam yang ditampilkan")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.gray)
                                Text("\(profile.greeting) Halo, \(profile.username)!")
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                        }
                        .padding(16)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)

                    // ── App Info ───────────────────────────────────────────
                    sectionHeader("Aplikasi")

                    VStack(spacing: 0) {
                        settingsRow(icon: "info.circle.fill", color: .blue, title: "Versi", value: "1.0.0")
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 120)
            }
        }
        .background(Color(white: 0.96).ignoresSafeArea())
    }

    // MARK: - Helpers

    private func saveName() {
        let trimmed = draftName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            profile.username = trimmed
        }
        isEditing = false
        fieldFocused = false
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.gray)
            .padding(.leading, 4)
    }

    @ViewBuilder
    private func settingsRow(icon: String, color: Color, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 32)
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.primary)
            Spacer()
            if !value.isEmpty {
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .padding(16)
    }
}

#Preview {
    ProfileSettingsView()
}

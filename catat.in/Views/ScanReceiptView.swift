import SwiftUI

struct ScanReceiptView: View {
    @Environment(\.presentationMode) var presentationMode
    var onScan: (() -> Void)?
    var onUpload: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
                Spacer()
                Text("Scan Struk Pengeluaran")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
                // Empty view for balancing back button
                Image(systemName: "arrow.left").opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Viewfinder area
                    ZStack {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color(red: 0.94, green: 0.9, blue: 0.88).opacity(0.8)) // pinkish beige background
                            .frame(height: 400)
                        
                        // Device mockup in the center
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(white: 0.3)) // dark gray device frame
                                .frame(width: 220, height: 320)
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white) // receipt bg
                                .frame(width: 200, height: 300)
                            
                            // Mock receipt text
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Receipt Total")
                                Text("Amount        $100")
                                Text("Date        10/20")
                                Spacer()
                            }
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                            .padding(24)
                            .frame(width: 200, height: 300, alignment: .topLeading)
                            
                            // "Posisikan struk dalam bingkai"
                            Text("Posisikan struk dalam bingkai")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(16)
                        }
                        
                        // Green Scanning Corners
                        VStack {
                            HStack {
                                CornerShape()
                                    .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 40, height: 40)
                                    .rotationEffect(.degrees(0))
                                Spacer()
                                CornerShape()
                                    .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 40, height: 40)
                                    .rotationEffect(.degrees(90))
                            }
                            Spacer()
                            HStack {
                                CornerShape()
                                    .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 40, height: 40)
                                    .rotationEffect(.degrees(-90))
                                Spacer()
                                CornerShape()
                                    .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                    .frame(width: 40, height: 40)
                                    .rotationEffect(.degrees(180))
                            }
                        }
                        .padding(32)
                        
                        // Scan line effect
                        Rectangle()
                            .fill(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.0), Color.green.opacity(0.4), Color.green.opacity(0.0)]), startPoint: .top, endPoint: .bottom))
                            .frame(height: 10)
                            .offset(y: -40) // mock offset
                    }
                    .padding(.horizontal, 24)
                    
                    Text("Catat.in akan mendeteksi nominal dan\nkategori belanja Anda secara otomatis dari\nstruk.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 16)
                    
                    // Controls inside a white card at bottom
                    VStack(spacing: 24) {
                        // Capture Controls
                        HStack(spacing: 32) {
                            Button(action: {}) {
                                ZStack {
                                    Circle()
                                        .fill(Color(white: 0.95))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Button(action: {}) {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.2))
                                        .frame(width: 80, height: 80)
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 64, height: 64)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Button(action: {}) {
                                ZStack {
                                    Circle()
                                        .fill(Color(white: 0.95))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "bolt.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.top, 24)
                        
                        // Actions
                        VStack(spacing: 16) {
                            Button(action: {
                                onScan?()
                            }) {
                                Text("Scan Sekarang")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.green)
                                    .cornerRadius(24)
                            }
                            
                            Button(action: {
                                onUpload?()
                            }) {
                                Text("Upload Gambar")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(white: 0.95))
                                    .cornerRadius(24)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                    .background(Color.white)
                    .cornerRadius(40, corners: [.topLeft, .topRight])
                    .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: -5)
                    .padding(.top, 16)
                }
            }
        }
        .background(Color(white: 0.98).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// Helper for UI view styling
struct CornerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        return path
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

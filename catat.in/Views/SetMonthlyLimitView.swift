import SwiftUI

struct SetMonthlyLimitView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var limitText: String = "2500.00"
    @State private var alertsOn: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                }
                Spacer()
                Text("Set Monthly Limit")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.left").opacity(0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 20)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Card Area with Top Image and Overlapping White Container
                    ZStack(alignment: .top) {
                        
                        // Top Green Background
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color(red: 0.2, green: 0.5, blue: 0.3)) // solid green
                            .frame(height: 220)
                        
                        // Stack of coins image placeholder overlay
                        Image(systemName: "coins") // using SF symbols to mock
                            .font(.system(size: 80))
                            .foregroundColor(.yellow.opacity(0.8))
                            .padding(.top, 40)
                        
                        // White Card overlapping
                        VStack(spacing: 24) {
                            HStack {
                                Text("CURRENT MONTHLY LIMIT")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("ACTIVE")
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(12)
                            }
                            
                            HStack {
                                Text("$2,500.00")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            
                            VStack(spacing: 8) {
                                HStack {
                                    Text("60% Used")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.3))
                                    Spacer()
                                    Text("$1,000.00 Remaining")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                                
                                // Progress bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.gray.opacity(0.15))
                                            .frame(height: 12)
                                        
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.green)
                                            .frame(width: geometry.size.width * 0.6, height: 12)
                                    }
                                }
                                .frame(height: 12)
                            }
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(32)
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        .offset(y: 150)
                    }
                    .padding(.bottom, 160) // accommodate for the overlap
                    
                    // Forms
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Edit Limit Details")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                        
                        Text("New Monthly Limit")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.4))
                            .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            Text("$")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.gray)
                            TextField("Amount", text: $limitText)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .keyboardType(.decimalPad)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(24)
                        .padding(.horizontal, 20)
                        
                        Text("Reset Cycle")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.2, green: 0.3, blue: 0.4))
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.gray)
                            Text("1st of every month")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(24)
                        .padding(.horizontal, 20)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Threshold Alerts")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                Text("Notify me when I reach 80%")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Toggle("", isOn: $alertsOn)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(24)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Save Changes")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.green)
                                .cornerRadius(24)
                        }
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                    
                }
            }
        }
        .background(Color(white: 0.96).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

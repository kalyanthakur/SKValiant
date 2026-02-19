//
//  LoginView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 30/01/26.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel = LoginViewModel()
    @State private var mobileNumber: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Main Badge Logo
                    badgeLogo
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                    // Login Form
                    loginForm
                        .padding(.horizontal, 32)
                    Spacer()
                    // Footer
                    footerSection
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                }
            }
            .background(.white)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image("SPOG_logo_2")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 226.0 / 255.0, green: 231.0 / 255.0, blue: 241.0 / 255.0), location: 0.0),
                        Gradient.Stop(color: Color(red: 196.0 / 255.0, green: 205.0 / 255.0, blue: 226.0 / 255.0), location: 1.0)],
                    startPoint: .bottom,
                    endPoint: .center),
                for: .navigationBar
            )
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(isPresented: $viewModel.showSuccess) {
                OTPView(mobileNumber: mobileNumber)
            }
        }
    }
    
    
    // MARK: - Badge Logo
    private var badgeLogo: some View {
        HStack(alignment: .center, spacing: 12) {
            Spacer()
            // Small badge logo
            Image("SPOG_logo")
                .font(.system(size: 24))
                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
            Spacer()
        }
    }
    
    // MARK: - Login Form
    private var loginForm: some View {
        VStack(spacing: 24) {
            // Welcome message
            Text("Welcome back! Please log into your account.")
                .font(.custom("HelveticaNeue-Medium", size: 12))
                .foregroundColor(Color("textColor"))
                .multilineTextAlignment(.center)
            
            // Email field
            VStack(alignment: .leading, spacing: 22) {
                
                TextField("Mobile Number/Email Address", text: $mobileNumber, prompt: Text("Mobile Number/Email Address")
                    .foregroundColor(Color("textColor")))
                    .font(.custom("HelveticaNeue-Medium", size: 12))
                    .foregroundColor(Color("textColor"))
                    .textFieldStyle(PlainTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)

                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            HStack {
                Spacer()
                // Sign In button
                Button(action: handleLogin) {
                    Text("Sign In")
                        .font(.custom("HelveticaNeue-Medium", size: 12))
                        .foregroundColor(.white)
                        .frame(width: 150)
                        .padding(.vertical,12)
                        .background(Color("bgColor"))
                        .cornerRadius(2)
                }
                Spacer()
            }
        }
    }
    
    private func handleLogin() {
        let status = viewModel.validateInput(mobileNumber)
        if status {
            viewModel.makeLoginRequest(text: mobileNumber)
        }
    }
    // MARK: - Footer Section
    private var footerSection: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 5) {
                Button(action: {
                    // Handle terms of use
                }) {
                    Text("Terms of use.")
                        .font(.custom("HelveticaNeue-Medium", size: 8))
                        .foregroundColor(Color("textColor"))
                        .underline(color: Color("textColor"))
                }
                
                Button(action: {
                    // Handle privacy policy
                }) {
                    Text("Privacy policy.")
                        .font(.custom("HelveticaNeue-Medium", size: 8))
                        .foregroundColor(Color("textColor"))
                        .underline(color: Color("textColor"))
                }
            }
            .padding(.trailing, 32)
            Spacer()

        }
    }
}

// MARK: - Custom Checkbox Toggle Style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack(spacing: 8) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? Color(red: 0.1, green: 0.2, blue: 0.4) : .gray)
                    .font(.system(size: 18))
                
                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Triangle Shape for Space Needle
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    LoginView()
}


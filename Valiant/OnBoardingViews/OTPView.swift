//
//  OTPView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//

import SwiftUI

struct OTPView: View {
    @ObservedObject var viewModel = LoginViewModel()
    @State private var inputText: String = ""
    @State private var mobileNumber: String = ""
    @State private var navigateToSignUp: Bool = false
    @State private var secondsRemaining = 30
    @State private var isTimerActive = true
    
    init(mobileNumber: String) {
        self._mobileNumber = State(initialValue: mobileNumber)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // OTP Form
                otpForm
                    .padding(.horizontal, 32)
                Spacer()
               
            }
        }
        .background(.white)
        .navigationBarBackButtonHidden()
        .task {
            startTimer()
        }
        .dismissKeyboardOnTap() // 👈 add this here
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
        .onChange(of: viewModel.showOTPSuccess) { success in
            if success {
                // Post notification to ContentView to handle navigation
                NotificationCenter.default.post(name: Notification.Name(NotificationNames.loginSuccess), object: nil)
            }
        }
    }

    // MARK: - OTP Form
    private var otpForm: some View {
        VStack(spacing: 24) {
            // Welcome message
            Text("Login to your account")
                .font(.custom("HelveticaNeue-Bold", size: 20))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 60)
            
            Text("OTP sent to your registered email and mobile number")
                .font(.custom("HelveticaNeue-Normal", size: 14))
                .foregroundColor(Color("textColor"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 15)
            
            Text("Enter OTP")
                .font(.custom("HelveticaNeue-Medium", size: 14))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Email field
            VStack(alignment: .leading, spacing: 22) {
                
                OTPTextField(otpText: $inputText)
                    .padding(.top, 8)
            }
            
            // Instructions
            VStack(spacing: 8) {
                Text("Didn’t receive the code?")
                    .font(.custom("HelveticaNeue-Medium", size: 12))
                    .foregroundColor(Color("textColor"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if isTimerActive {
                    Text("\(timeFormatted(secondsRemaining))")
                        .foregroundColor(.red)
                        .font(.custom("HelveticaNeue-Medium", size: 12))
                } else {
                    Button("Re-send code") {
                        // Re-send code action
                        viewModel.makeLoginRequest(text: mobileNumber)
                        startTimer()
                    }
                    .buttonStyle(.plain)
                    .font(.custom("HelveticaNeue-Medium", size: 12))
                    .foregroundColor(.red)
                }
            }.padding(.vertical, 30)
            
            HStack {
                Spacer()
                // Sign In button
                Button(action: handleVerify) {
                    Text("Submit")
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
    
    private func handleVerify() {
        let status = viewModel.validateOTPInput(inputText)
        if status {
            viewModel.makeOTPVerifyRequest(contactNo: mobileNumber, otp: inputText)
        }
        
    }
    
    // MARK: - Timer Logic
    func startTimer() {
        secondsRemaining = 30
        isTimerActive = true
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                timer.invalidate()
                isTimerActive = false
            }
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

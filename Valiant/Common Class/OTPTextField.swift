//
//  OTPTextField.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//

import SwiftUI

struct OTPTextField: View {
    @Binding var otpText: String
    let length: Int = 4
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            HStack(spacing: 16) {
                ForEach(0..<length, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                            .frame(width: 52, height: 52)
                        
                        Text(charAt(index))
                            .font(.custom("HelveticaNeue-Medium", size: 20))
                            .foregroundColor(Color("textColor"))
                    }
                }
            }
            
            // Hidden TextField to capture input
            TextField("", text: $otpText)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isFocused)
                .onChange(of: otpText) {
                    // Limit input length
                    if otpText.count > length {
                        otpText = String(otpText.prefix(length))
                    }
                }
                .frame(width: 0, height: 0)
                .opacity(0)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isFocused = true
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }
    
    private func charAt(_ index: Int) -> String {
        guard index < otpText.count else { return "" }
        let charIndex = otpText.index(otpText.startIndex, offsetBy: index)
        return String(otpText[charIndex])
    }
}

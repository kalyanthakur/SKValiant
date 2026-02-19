//
//  RequestSuccessView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 09/02/26.
//

import SwiftUI

struct RequestSuccessView: View {
    let onDismiss: (() -> Void)?
    @State private var message: String = ""
    @State private var description: NSMutableAttributedString = NSMutableAttributedString()

    
    init(onDismiss: (() -> Void)? = nil, title: String, description: NSMutableAttributedString) {
        self.onDismiss = onDismiss
        self._message = State(initialValue: title)
        self._description = State(initialValue: description)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                
                HStack(spacing: 16) {
                    Text(message)
                        .font(.custom("Helvetica-Bold", size: 16.0))
                        .foregroundColor(Color(red: 34.0 / 255.0, green: 38.0 / 255.0, blue: 38.0 / 255.0))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 15)
                
                // Instructional text
                AttributedTextView(attributedString: description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .frame(width: geometry.size.width-64, height: 100)

                
                Image("SPOG_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width-100, height: geometry.size.width)
                
                Spacer()
            }
        }
        .background(.white)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // Go back to previous to previous screen
                    onDismiss?()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                Image("SPOG_logo_2")
                    .font(.system(size: 28))
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
    }

}

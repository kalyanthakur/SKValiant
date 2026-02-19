//
//  SplashView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 30/01/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image("SPOG_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Text("Seattle Police Officers Guild ")
                    .font(.custom("OpenSans-Semibold", size: 16.0))
                    .foregroundColor(Color(white: 0.0))
                    .multilineTextAlignment(.center)
                    .underline()
                    .textCase(.uppercase)
                    .frame(height: 11.0, alignment: .center)
                Text("Seattle's Public Safety Voice")
                    .font(.custom("OpenSans-Semibold", size: 12.0))
                    .foregroundColor(Color(white: 0.0))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    SplashView()
}


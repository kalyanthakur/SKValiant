//
//  InfoCard.swift
//  Valiant
//
//  Created by Kalyan Thakur on 10/02/26.
//

import SwiftUI

struct InfoCard: View {
    let width: CGFloat
    let menu: MenuItems
    let isForProfile: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: max(0, width-32), height: 60.0)
                    .background(LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 226.0 / 255.0, green: 231.0 / 255.0, blue: 241.0 / 255.0), location: 0.0),
                            Gradient.Stop(color: Color(red: 196.0 / 255.0, green: 205.0 / 255.0, blue: 226.0 / 255.0), location: 1.0)],
                        startPoint: .bottom,
                        endPoint: .bottomLeading))
                    .cornerRadius(2)
                
                VStack (alignment: .leading) {
                    HStack(spacing: 20) {
                        Image(menu.icon ?? "")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        
                        
                        Text(menu.name ?? "")
                            .font(.custom("HelveticaNeue-Bold", size: 12.0))
                            .foregroundColor(Color(red: 19.0 / 255.0, green: 59.0 / 255.0, blue: 58.0 / 255.0))
                            .multilineTextAlignment( isForProfile ? .center : .leading)
                            .frame(maxWidth: .infinity, alignment: isForProfile ? .center : .leading)
                            
                        
                        Spacer()
                        
                    }
                    .padding(.horizontal, isForProfile ? 16 : 8)
                }
            }
        }
    }
}

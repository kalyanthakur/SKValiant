//
//  LatestAlertCard.swift
//  Valiant
//
//  Created by Kalyan Thakur on 06/02/26.
//

import SwiftUI

struct LatestAlertCard: View {
    let width: CGFloat
    let alert: SpogAlert
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: width-32, height: 250.0)
                    .background(LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 226.0 / 255.0, green: 231.0 / 255.0, blue: 241.0 / 255.0), location: 0.0),
                            Gradient.Stop(color: Color(red: 196.0 / 255.0, green: 205.0 / 255.0, blue: 226.0 / 255.0), location: 1.0)],
                        startPoint: .bottom,
                        endPoint: .bottomLeading))
                    .cornerRadius(2)
                
                VStack (alignment: .leading) {
                    AlertCard(alert: alert, width: width-32)
                        .padding(8)
                }
            }
        }
    }
}


struct AlertCard: View {
    let alert: SpogAlert
    let width: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text("LATEST")
                .font(.custom("HelveticaNeue-Regular", size: 14.0))
                .foregroundColor(Color(white: 112.0 / 255.0))
                .multilineTextAlignment(.leading)

            // Alert Image
            if let imagePath = alert.image, !imagePath.isEmpty {
                let imageURL = appSharedData.constructImageURL(from: imagePath)
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 80, height: 80)
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: width-32, height: 130)
                    case .failure:
                        // Fallback to SPOG logo if image fails to load
                        Image("SPOG_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    @unknown default:
                        Image("SPOG_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    }
                }
            } else {
                // Default SPOG logo if no image
                Image("SPOG_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
            }
            
            // Title
            HTMLText(html: alert.title, color: "#133b3a", fontSize: 14)
                        
            // Date
            Text(appSharedData.convertDateFormatFromForDate(fromFormat: "yyyy-MM-dd", toFormat: "MMM,dd,yyyy", stringDate: alert.date))
                .font(.custom("Roboto-Regular", size: 10.0))
                .foregroundColor(Color(hex: "#173b8d"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
    }
}


struct OtherCard: View {
    let alert: SpogAlert
    let width: CGFloat

    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: max(0, width-32), height: 110.0)
                    .background(LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 226.0 / 255.0, green: 231.0 / 255.0, blue: 241.0 / 255.0), location: 0.0),
                            Gradient.Stop(color: Color(red: 196.0 / 255.0, green: 205.0 / 255.0, blue: 226.0 / 255.0), location: 1.0)],
                        startPoint: .bottom,
                        endPoint: .bottomLeading))
                    .cornerRadius(2)
                
                HStack(spacing: 12) {
                    // Alert Image
                    if let imagePath = alert.image, !imagePath.isEmpty {
                        let imageURL = appSharedData.constructImageURL(from: imagePath)
                        AsyncImage(url: URL(string: imageURL)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 80, height: 80)
                            case .success(let image):
                                image
                                    .resizable()
                                    .cornerRadius(8)
                                    .frame(width: 110, height: 90)
                            case .failure:
                                // Fallback to SPOG logo if image fails to load
                                Image("SPOG_logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                            @unknown default:
                                Image("SPOG_logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                            }
                        }
                    } else {
                        // Default SPOG logo if no image
                        Image("SPOG_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    }
                    
                    VStack {
                        // Title
                        HTMLText(html: alert.title, color: "#133b3a", fontSize: 11)
                        
                        // Date
                        Text(appSharedData.convertDateFormatFromForDate(fromFormat: "yyyy-MM-dd", toFormat: "MMM,dd,yyyy", stringDate: alert.date))
                            .font(.custom("Roboto-Regular", size: 10.0))
                            .foregroundColor(Color("textColor"))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(8)
            }
        }
        .frame(width: width-32)

    }
}

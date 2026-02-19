//
//  FeatureSholarship.swift
//  Valiant
//
//  Created by Kalyan Thakur on 11/02/26.
//

import SwiftUI

struct FeatureSholarship: View {
    let width: CGFloat
    let scholarship: Scholarship
    
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
                    FeatureSholarshipCard(scholarship: scholarship, width: width-32)
                        .padding(8)
                }
            }
        }
    }
}

struct FeatureSholarshipCard: View {
    let scholarship: Scholarship
    let width: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("FEATURED")
                    .font(.custom("HelveticaNeue-Regular", size: 14.0))
                    .foregroundColor(Color(white: 112.0 / 255.0))
                    .multilineTextAlignment(.leading)
                
                Spacer()
            
            }

            // Alert Image
            if !scholarship.coverImg.isEmpty {
                let imageURL = appSharedData.constructImageURL(from: scholarship.coverImg)
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
            HTMLText(html: scholarship.title, color: "#133b3a", fontSize: 14)
                     
            let eventDate = appSharedData.convertDateFormatFromForDate(fromFormat: "yyyy-MM-dd", toFormat: "MMM dd, yyyy ", stringDate: scholarship.date)
            // Date
            Text("\(eventDate)")
                .font(.custom("Roboto-Regular", size: 10.0))
                .foregroundColor(Color(red: 23.0 / 255.0, green: 59.0 / 255.0, blue: 141.0 / 255.0))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
    }
}


struct SholarshipCard: View {
    let width: CGFloat
    let scholarship: Scholarship

    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: width-32, height: 80.0)
                    .background(LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 226.0 / 255.0, green: 231.0 / 255.0, blue: 241.0 / 255.0), location: 0.0),
                            Gradient.Stop(color: Color(red: 196.0 / 255.0, green: 205.0 / 255.0, blue: 226.0 / 255.0), location: 1.0)],
                        startPoint: .bottom,
                        endPoint: .bottomLeading))
                    .cornerRadius(2)
                
                VStack (alignment: .leading) {
                    HStack(spacing: 20) {
                        if !scholarship.coverImg.isEmpty {
                            let imageURL = appSharedData.constructImageURL(from: scholarship.coverImg)
                            AsyncImage(url: URL(string: imageURL)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 60, height: 60)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(30)
                                case .failure:
                                    // Fallback to SPOG logo if image fails to load
                                    Image("SPOG_logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                @unknown default:
                                    Image("SPOG_logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                }
                            }
                        } else {
                            // Default SPOG logo if no image
                            Image("SPOG_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                        }
                        
                        
                        VStack(spacing:8) {
                            Text(scholarship.title)
                                .font(.custom("HelveticaNeue-Bold", size: 14.0))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let eventDate = appSharedData.convertDateFormatFromForDate(fromFormat: "yyyy-MM-dd", toFormat: "MMM dd, yyyy ", stringDate: scholarship.date)
                            // Date
                            Text("Date : \(eventDate)")
                                .font(.custom("Roboto-Regular", size: 10.0))
                                .foregroundColor(Color(white: 112.0 / 255.0))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Spacer()
                        
                    }
                    .padding(.horizontal, 30)
                }
            }
        }
    }
}

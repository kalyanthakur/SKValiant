//
//  SPOGAlertCard.swift
//  Valiant
//
//  Created by Kalyan Thakur on 04/02/26.
//

import SwiftUI


// MARK: - SPOG Alert Card
struct SPOGAlertCard: View {
    let alert: SpogAlert
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 12) {
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
                                .frame(width: geometry.size.width-20, height: 130)
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
                HTMLText(html: alert.title, color: "#133b3a", fontSize: 11)
                            
                // Date
                Text(appSharedData.convertDateFormatFromForDate(fromFormat: "yyyy-MM-dd", toFormat: "MMM,dd,yyyy", stringDate: alert.date))
                    .font(.custom("Roboto-Regular", size: 10.0))
                    .foregroundColor(Color(red: 23.0 / 255.0, green: 59.0 / 255.0, blue: 141.0 / 255.0))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: geometry.size.width)
            .padding(.leading, 8)
        }
        .frame(width: UIScreen.main.bounds.width - 80, height: 200) // Dynamic width based on screen size minus padding
    }
}


struct HTMLText: View {
    let html: String
    let color: String
    let fontSize: Int
    
    
    var body: some View {
        if let data = """
<style>body {font-family: Roboto-Regular;font-size: \(fontSize)px;color:\(color);}p {margin: 0;padding: 0;}</style>\(html)
""".data(using: .utf8),
           let attributedString = try? AttributedString(
                NSAttributedString(
                    data: data,
                    options: [
                        .documentType: NSAttributedString.DocumentType.html,
                        .characterEncoding: String.Encoding.utf8.rawValue
                    ],
                    documentAttributes: nil
                )
           ) {
            Text(attributedString)
                .font(.custom("Roboto-Regular", size: CGFloat(fontSize)))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text(html) // fallback
                .font(.custom("Roboto-Regular", size: CGFloat(fontSize)))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

//
//  EventCard.swift
//  Valiant
//
//  Created by Kalyan Thakur on 04/02/26.
//

import SwiftUI

struct EventCard: View {
    let event: SpogEvent
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 12) {
                // Alert Image
                if let imagePath = event.image, !imagePath.isEmpty {
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
                
                // Title
                HTMLText(html: event.title, color: "#133b3a", fontSize: 18)
                        
            }
            .frame(width: geometry.size.width)
            .padding(.leading, 8)
        }
        .frame(width: UIScreen.main.bounds.width - 80) // Dynamic width based on screen size minus padding
    }
}

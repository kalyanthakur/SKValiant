//
//  LatestMessageCard.swift
//  Valiant
//
//  Created by Kalyan Thakur on 08/02/26.
//

import SwiftUI

struct LatestMessageCard: View {
    let width: CGFloat
    let message: PresidentsMessage
    @ObservedObject var viewModel: MessageViewModel
    
    var body: some View {
        VStack (alignment: .leading) {
            SingleMessageCard(message: message, width: width-32, viewModel: viewModel)
                .padding(8)
        }
        .background(LinearGradient(
            stops: [
                Gradient.Stop(color: Color(red: 226.0 / 255.0, green: 231.0 / 255.0, blue: 241.0 / 255.0), location: 0.0),
                Gradient.Stop(color: Color(red: 196.0 / 255.0, green: 205.0 / 255.0, blue: 226.0 / 255.0), location: 1.0)],
            startPoint: .bottom,
            endPoint: .bottomLeading))
        .cornerRadius(2)
    }
}

struct SingleMessageCard: View {
    let message: PresidentsMessage
    let width: CGFloat
    @ObservedObject var viewModel: MessageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("LATEST")
                    .font(.custom("HelveticaNeue-Regular", size: 14.0))
                    .foregroundColor(Color(white: 112.0 / 255.0))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button(action: {
                    let newBookmarkStatus = message.isBookmark ? 0 : 1
                    viewModel.bookmarkPost(itemType: "president_message", itemId: message.id, isBookmark: newBookmarkStatus)
                }) {
                    Image(systemName: message.isBookmark ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                }
            }

            // Alert Image
            if let imagePath = message.image, !imagePath.isEmpty {
                let imageURL = appSharedData.constructImageURL(from: imagePath)
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 80, height: 80)
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: width-32, height: (width-32)/2)
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
            HTMLText(html: message.title, color: "#133b3a", fontSize: 14)
                     
            let eventDate = appSharedData.convertDateFormatFromForDate(fromFormat: "yyyy-MM-dd", toFormat: "MMM dd, yyyy ", stringDate: message.date)
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

struct OtherMessageCard: View {
    let message: PresidentsMessage
    let width: CGFloat
    @ObservedObject var viewModel: MessageViewModel

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
                
                HStack(alignment: .top, spacing: 12) {
                    // Alert Image
                    if let imagePath = message.image, !imagePath.isEmpty {
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
                    
                    VStack(spacing: 5) {
                        // Title
                        HTMLText(html: message.title, color: "#133b3a", fontSize: 11)
                        
                        // Date
                        Text(appSharedData.convertDateFormatFromForDate(fromFormat: "yyyy-MM-dd", toFormat: "MMM,dd,yyyy", stringDate: message.date))
                            .font(.custom("Roboto-Regular", size: 10.0))
                            .foregroundColor(Color("textColor"))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button(action: {
                        let newBookmarkStatus = message.isBookmark ? 0 : 1
                        viewModel.bookmarkPost(itemType: "president_message", itemId: message.id, isBookmark: newBookmarkStatus)
                    }) {
                        Image(systemName: message.isBookmark ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                    }
                }
                .padding(8)
            }
        }
        .frame(width: width-32)

    }
}

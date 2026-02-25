//
//  DocumentCard.swift
//  Valiant
//
//  Created by Kalyan Thakur on 08/02/26.
//

import SwiftUI

struct FeatureCard: View {
    let width: CGFloat
    let document: DocumentItem
    @ObservedObject var viewModel: DocumentViewModel
    
    var body: some View {
        VStack (alignment: .leading) {
            FeatureDocumentCard(document: document, width: width-32, viewModel: viewModel)
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

struct FeatureDocumentCard: View {
    let document: DocumentItem
    let width: CGFloat
    @ObservedObject var viewModel: DocumentViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("FEATURED")
                    .font(.custom("HelveticaNeue-Regular", size: 14.0))
                    .foregroundColor(Color(white: 112.0 / 255.0))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button(action: {
                    let newBookmarkStatus = (document.isBookmark ?? false) ? 0 : 1
                    viewModel.bookmarkPost(itemType: "spog_document", itemId: document.id, isBookmark: newBookmarkStatus)
                }) {
                    Image(systemName: (document.isBookmark ?? false) ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                }
            }

            // Alert Image
            if let imagePath = document.image, !imagePath.isEmpty {
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
            HTMLText(html: document.title, color: "#133b3a", fontSize: 14)
                     
            let eventDate = appSharedData.convertDateFormatFromForDate(fromFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", toFormat: "MMM dd, yyyy ", stringDate: document.createdAt ?? "")
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


struct DocumentCard: View {
    let width: CGFloat
    let document: DocumentItem
    @ObservedObject var viewModel: DocumentViewModel
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: width-32, height: 60.0)
                    .background(LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 226.0 / 255.0, green: 231.0 / 255.0, blue: 241.0 / 255.0), location: 0.0),
                            Gradient.Stop(color: Color(red: 196.0 / 255.0, green: 205.0 / 255.0, blue: 226.0 / 255.0), location: 1.0)],
                        startPoint: .bottom,
                        endPoint: .bottomLeading))
                    .cornerRadius(2)
                
                VStack (alignment: .leading) {
                    HStack {
                        if let imagePath = document.icon, !imagePath.isEmpty {
                            let imageURL = appSharedData.constructImageURL(from: imagePath)
                            AsyncImage(url: URL(string: imageURL)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 40, height: 40)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                case .failure:
                                    // Fallback to SPOG logo if image fails to load
                                    Image("SPOG_logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                @unknown default:
                                    Image("SPOG_logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                }
                            }
                        } else {
                            // Default SPOG logo if no image
                            Image("SPOG_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        }
                        
                        Spacer()
                        
                        Text(document.documentName)
                            .font(.custom("HelveticaNeue-Bold", size: 14.0))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Button(action: {
                            let newBookmarkStatus = (document.isBookmark ?? false) ? 0 : 1
                            viewModel.bookmarkPost(itemType: "spog_document", itemId: document.id, isBookmark: newBookmarkStatus)
                        }) {
                            Image(systemName: (document.isBookmark ?? false) ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                        }
                    }
                    .padding(.horizontal, 30)
                }
            }
        }
    }
}

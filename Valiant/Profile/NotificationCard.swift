//
//  NotificationCard.swift
//  Valiant
//
//  Created by Kalyan Thakur on 11/02/26.
//

import SwiftUI

struct LatestNotificationCard: View {
    let width: CGFloat
    let notification: NotificationItem
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: width, height: 120.0)
                    .background(LinearGradient(
                        stops: [
                            Gradient.Stop(color: (notification.isRead ?? false) ? Color(hex: "#e2e7f1") : Color(hex: "#F4F4F4"), location: 0.0),
                            Gradient.Stop(color: (notification.isRead ?? false) ? Color(hex: "#c4cde2") : Color(hex: "#e2e7f1"), location: 1.0)],
                        startPoint: .bottom,
                        endPoint: .bottomLeading))
                    .cornerRadius(2)
                
                VStack (alignment: .leading,spacing: 16) {
                    Text("LATEST NOTIFICATION")
                        .font(.custom("HelveticaNeue-Regular", size: 14.0))
                        .foregroundColor(Color(white: 112.0 / 255.0))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 8) {
                        // Unread dot indicator
                        if !(notification.isRead ?? false) {
                            Circle()
                                .fill(Color(hex: "#2196f3"))
                                .frame(width: 8, height: 8)
                                .frame(maxHeight: .infinity, alignment: .center)
                        }
                        
                        VStack(alignment: .leading,spacing: 8) {
                            Text(notification.title ?? "")
                                .font(.custom("HelveticaNeue-Medium", size: 14.0))
                                .foregroundColor(Color(hex: "#17393b"))
                                .multilineTextAlignment(.leading)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(notification.message ?? "")
                                .font(.custom("HelveticaNeue-Regular", size: 10.0))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            let eventDate = appSharedData.convertDateFormatFromForDate(fromFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", toFormat: "MMM dd, yyyy ", stringDate: notification.scheduledAt ?? "2026-01-05T07:30:00.000Z")
                            // Date
                            Text("\(eventDate)")
                                .font(.custom("Roboto-Regular", size: 8.0))
                                .foregroundColor(Color(red: 23.0 / 255.0, green: 59.0 / 255.0, blue: 141.0 / 255.0))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}



struct NotificationCard: View {
    let width: CGFloat
    let notification: NotificationItem
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: width, height: 100.0)
                    .background(LinearGradient(
                        stops: [
                            Gradient.Stop(color: (notification.isRead ?? false) ? Color(hex: "#e2e7f1") : Color(hex: "#F4F4F4"), location: 0.0),
                            Gradient.Stop(color: (notification.isRead ?? false) ? Color(hex: "#c4cde2") : Color(hex: "#e2e7f1"), location: 1.0)],
                        startPoint: .bottom,
                        endPoint: .bottomLeading))
                    .cornerRadius(2)
                
                HStack(spacing: 8) {
                    // Unread dot indicator
                    if !(notification.isRead ?? false) {
                        Circle()
                            .fill(Color(hex: "#2196f3"))
                            .frame(width: 8, height: 8)
                            .frame(maxHeight: .infinity, alignment: .center)
                    }
                    
                    VStack(alignment: .leading,spacing: 8) {
                        Text(notification.title ?? "")
                            .font(.custom("HelveticaNeue-Medium", size: 14.0))
                            .foregroundColor(Color(hex: "#17393b"))
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(notification.message ?? "")
                            .font(.custom("HelveticaNeue-Regular", size: 10.0))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        let eventDate = appSharedData.convertDateFormatFromForDate(fromFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", toFormat: "MMM dd, yyyy ", stringDate: notification.scheduledAt ?? "2026-01-05T07:30:00.000Z")
                        // Date
                        Text("\(eventDate)")
                            .font(.custom("Roboto-Regular", size: 8.0))
                            .foregroundColor(Color(white: 112.0 / 255.0))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}

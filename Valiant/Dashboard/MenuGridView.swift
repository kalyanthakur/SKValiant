//
//  MenuGridView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 06/02/26.
//

import SwiftUI

struct MenuGridView: View {
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    let screenWidth: CGFloat
    
    let arrMenus = [
        MenuItems(id: 1, name: "SPOG\nAlerts", icon: "ic_alert"),
        MenuItems(id: 2, name: "SPOG\nEvents", icon: "ic_calendar_s"),
        MenuItems(id: 3, name: "President's\nMessage", icon: "ic_president_message_s"),
        MenuItems(id: 4, name: "Official SPOG\nDocuments", icon: "ic_spog_documents"),
        MenuItems(id: 5, name: "Request a\nGuid Rep", icon: "ic_request"),
        MenuItems(id: 6, name: "Contact\nSPOG", icon: "ic_contact"),
    ]
    
    // Action handlers
    let onMenuTap: (Int) -> Void
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Title
            Text("SHORTCUTS")
                .font(.custom("HelveticaNeue-Regular", size: 14.0))
                .foregroundColor(Color(white: 112.0 / 255.0))
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
            
            // Grid of menu items
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(arrMenus, id: \.id) { menu in
                    NavigationItem(
                        title: menu.name ?? "",
                        icon: menu.icon ?? "",
                        width: max(100, (screenWidth - 60) / 3)
                    )
                    .onTapGesture {
                        onMenuTap(menu.id ?? 0)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 16)
    }
}

struct NavigationItem: View {
    let title: String
    let icon: String
    let width: CGFloat
    
    // Ensure width is always valid (positive and finite)
    private var validWidth: CGFloat {
        guard width.isFinite && width > 0 else {
            return 100 // Default minimum width
        }
        return width
    }
    
    private var iconSize: CGFloat {
        return min(validWidth * 0.6, 60)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Circular icon background
            ZStack {                
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(Color(red: 23.0 / 255.0, green: 59.0 / 255.0, blue: 141.0 / 255.0))
            }
            
            // Text label below
            Text(title)
                .font(.custom("HelveticaNeue-Regular", size: 12))
                .foregroundColor(Color("textColor"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: validWidth)
        }
        .frame(width: validWidth)
    }
}

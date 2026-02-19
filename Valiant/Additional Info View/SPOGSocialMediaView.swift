//
//  SPOGSocialMediaView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 10/02/26.
//

import SwiftUI
import WebKit
import UIKit

struct SPOGSocialMediaView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var isMenuSelected = false
    @State private var showDashboardView = false
    @State private var showAlertListView = false
    @State private var showCalendarView = false
    @State private var showEventListView = false
    @State private var showMessageView = false
    @State private var showDocumentView = false
    @State private var showContactSpogView = false
    @State private var showRequestGuidRepView = false
    @State private var showAdditionalInfoView = false
    @State private var showProfileView = false

    let arrMenus = [
        MenuItems(id: 1, name: "Latest Twitter", icon: "ic_x"),
        MenuItems(id: 2, name: "Connect with SPOG on X (formerly Twitter).", icon: "ic_x"),
        MenuItems(id: 3, name: "Like & Follow SPOG on Facebook.", icon: "ic_fb"),
        MenuItems(id: 4, name: "Follow SPOG on Instagram.", icon: "ic_insta"),
        MenuItems(id: 5, name: "Subscribe to the SPOG YouTube channel.", icon: "ic_youtube"),
        MenuItems(id: 6, name: "Watch SPOG’s podcast, Hold the Line with Mike Solan", icon: "ic_htl2")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                
                HStack(spacing: 16) {
                    Text("SPOG on Social Media")
                        .font(.custom("HelveticaNeue-Bold", size: 16.0))
                        .foregroundColor(Color(red: 34.0 / 255.0, green: 38.0 / 255.0, blue: 38.0 / 255.0))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 8)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(arrMenus, id: \.id) { menu in
                            if menu.id == 1 {
                                LatestInfoCard(width: geometry.size.width-32)
                            } else {
                                InfoCard(width: max(0, geometry.size.width-32), menu: menu, isForProfile: false)
                                    .onTapGesture {
                                        switch menu.id {
                                        case 2:
                                            // Open Twitter/X link in Safari
                                            if let url = URL(string: "https://x.com/SPOG1952") {
                                                UIApplication.shared.open(url)
                                            }
                                        case 3:
                                            // Add Facebook link here if needed
                                            if let url = URL(string: "https://www.facebook.com/seattlepoliceofficers") {
                                                UIApplication.shared.open(url)
                                            }
                                            
                                        case 4:
                                            // Add Instagram link here if needed
                                            if let url = URL(string: "https://www.instagram.com/official_spog/") {
                                                UIApplication.shared.open(url)
                                            }
                                        case 5:
                                            // Add YouTube link here if needed
                                            if let url = URL(string: "https://www.youtube.com/@SPOG") {
                                                UIApplication.shared.open(url)
                                            }
                                        case 6:
                                            // Add podcast link here if needed
                                            if let url = URL(string: "https://www.youtube.com/@HTLwithMSolan") {
                                                UIApplication.shared.open(url)
                                            }
                                        default:
                                            break
                                        }
                                    }
                            }
                        }
                            
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.top, 16)
                
                }
                .background(.white)
                
                // Floating Menu Button
                FloatingMenuActionButton(
                    isSelected: $isMenuSelected,
                    floatingMenuItems: generateFloatingMenuItems()
                )
                .padding(.trailing, 8)
                .padding(.bottom, 30)
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Image("SPOG_logo_2")
                        .font(.system(size: 28))
                        .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 226.0 / 255.0, green: 231.0 / 255.0, blue: 241.0 / 255.0), location: 0.0),
                        Gradient.Stop(color: Color(red: 196.0 / 255.0, green: 205.0 / 255.0, blue: 226.0 / 255.0), location: 1.0)],
                    startPoint: .bottom,
                    endPoint: .center),
                for: .navigationBar
            )
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(isPresented: $showDashboardView) {
                if showDashboardView {
                    DashBoardView()
                }
            }
            .navigationDestination(isPresented: $showAlertListView) {
                if showAlertListView {
                    AlertListView()
                }
            }
            .navigationDestination(isPresented: $showCalendarView) {
                if showCalendarView {
                    CalendarListView()
                }
            }
            .navigationDestination(isPresented: $showEventListView) {
                if showEventListView {
                    EventListView()
                }
            }
            .navigationDestination(isPresented: $showMessageView) {
                if showMessageView {
                    PresidentMessageListView()
                }
            }
            .navigationDestination(isPresented: $showDocumentView) {
                if showDocumentView {
                    DocumentListView()
                }
            }
            .navigationDestination(isPresented: $showContactSpogView) {
                if showContactSpogView {
                    ContactSpogView(onCompleteDismiss: {
                        showContactSpogView = false
                    })
                }
            }
            .navigationDestination(isPresented: $showAdditionalInfoView) {
                if showAdditionalInfoView {
                    AdditionalInfoView()
                }
            }
            .navigationDestination(isPresented: $showRequestGuidRepView) {
                if showRequestGuidRepView {
                    RequestGuidRep(onCompleteDismiss: {
                        showRequestGuidRepView = false
                    })
                }
            }
            .navigationDestination(isPresented: $showProfileView) {
                if showProfileView {
                    ProfileView()
                }
            }
        }
    }
    
    // MARK: - Floating Menu Items
    private func generateFloatingMenuItems() -> [FloatingMenuItem] {
        return [
            .init(iconName: "ic_home", buttonAction: {
                showDashboardView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_bell", buttonAction: {
                showAlertListView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_calendar", buttonAction: {
                showCalendarView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_president_message", buttonAction: {
                showMessageView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_contact_shortcut", buttonAction: {
                showRequestGuidRepView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_more", buttonAction: {
                // Already on additional info, just close menu
                showAdditionalInfoView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_user", buttonAction: {
                // Add user actions here
                showProfileView = true
                isMenuSelected = false
            }),
        ]
    }
}

#Preview {
    SPOGSocialMediaView()
}


struct LatestInfoCard: View {
    let width: CGFloat
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: max(0, width-32), height: 450.0)
                    .background(LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 226.0 / 255.0, green: 231.0 / 255.0, blue: 241.0 / 255.0), location: 0.0),
                            Gradient.Stop(color: Color(red: 196.0 / 255.0, green: 205.0 / 255.0, blue: 226.0 / 255.0), location: 1.0)],
                        startPoint: .bottom,
                        endPoint: .bottomLeading))
                    .cornerRadius(2)
                
                VStack (alignment: .leading) {
                    TwitterCard()
                        .padding(8)
                }
            }
        }
    }
}

struct TwitterCard: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("LATEST")
                    .font(.custom("HelveticaNeue-Regular", size: 14.0))
                    .foregroundColor(Color(white: 112.0 / 255.0))
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            
            // WebView to display tweets
            WebView(urlString: "https://valiant.sourcekode.in/api/tweets")
                .frame(height: 400)
                .cornerRadius(8)
        
        }
    }
}

// MARK: - WebView Component
struct WebView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Optional: Handle page load completion
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            // Optional: Handle navigation errors
            print("WebView navigation error: \(error.localizedDescription)")
        }
    }
}

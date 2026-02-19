//
//  ProfileView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 11/02/26.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject var viewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isMenuSelected = false
    @State private var showDashboardView = false
    @State private var showAlertListView = false
    @State private var showCalendarView = false
    @State private var showEventListView = false
    @State private var showMessageView = false
    @State private var showDocumentView = false
    @State private var showContactSpogView = false
    @State private var showAdditionalInfoView = false
    @State private var showRequestGuidRepView = false

    @State private var showAccountView = false
    @State private var showNotificationView = false
    @State private var showBookmarkView = false
    @State private var showSupportView = false
    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false

    let arrMenus = [
        MenuItems(id: 1, name: "Account", icon: "ic_fallen_officers"),
        MenuItems(id: 2, name: "Notifications", icon: "ic_messages"),
        MenuItems(id: 3, name: "Bookmarks", icon: "ic_bookmark"),
        MenuItems(id: 4, name: "Support", icon: "ic_support_menu"),
        MenuItems(id: 5, name: "Logout", icon: "logout"),
        MenuItems(id: 6, name: "Delete Account", icon: "delete")
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .center, spacing: 16) {
                            Text("Profile")
                                .font(.custom("HelveticaNeue-Bold", size: 16.0))
                                .foregroundColor(Color(red: 34.0 / 255.0, green: 38.0 / 255.0, blue: 38.0 / 255.0))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            if let userData = appUserDefaults.userData {
                                ZStack(alignment: .bottomTrailing) {
                                    if let imagePath = userData.profileImage, !imagePath.isEmpty {
                                        let imageURL = appSharedData.constructImageURL(from: imagePath)
                                        AsyncImage(url: URL(string: imageURL)) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                                    .cornerRadius(60)
                                                    .frame(width: 120, height: 120)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .cornerRadius(60)
                                                    .frame(width: 120, height: 120)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.gray, lineWidth: 1)
                                                    )
                                            case .failure:
                                                // Fallback to SPOG logo if image fails to load
                                                Image("SPOG_logo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .cornerRadius(60)
                                                    .frame(width: 120, height: 120)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.gray, lineWidth: 1)
                                                    )
                                            @unknown default:
                                                Image("SPOG_logo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .cornerRadius(60)
                                                    .frame(width: 120, height: 120)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.gray, lineWidth: 1)
                                                    )
                                            }
                                        }
                                    } else {
                                        Image("SPOG_logo")
                                            .resizable()
                                            .scaledToFit()
                                            .cornerRadius(60)
                                            .frame(width: 120, height: 120)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.gray, lineWidth: 1)
                                            )
                                    }
                                    
                                    // Edit button - half inside, half outside
                                    Button(action: {
                                        // Handle edit action
                                        showAccountView.toggle()
                                    }) {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white)
                                            .frame(width: 28, height: 28)
                                            .background(Color(red: 0.1, green: 0.2, blue: 0.4))
                                            .clipShape(Circle())
                                    }
                                    .offset(x: 0, y: -4)
                                }
                                .frame(width: 120, height: 120)

                                
                                VStack {
                                    Text(userData.name ?? "")
                                        .font(.custom("Roboto-Medium", size: 16.0))
                                        .foregroundColor(Color(red: 34.0 / 255.0, green: 38.0 / 255.0, blue: 38.0 / 255.0))
                                        .multilineTextAlignment(.center)
                                    
                                    Text(userData.email ?? "")
                                        .font(.custom("Roboto-Medium", size: 12.0))
                                        .foregroundColor(Color(red: 34.0 / 255.0, green: 38.0 / 255.0, blue: 38.0 / 255.0))
                                        .multilineTextAlignment(.center)
                                    
                                    let createdAt = appSharedData.convertDateFormatFromForDate(fromFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", toFormat: "MMM dd, yyyy ", stringDate: userData.createdAt ?? "2025-12-17T17:03:19.000Z")

                                    Text("Member Since \(createdAt)")                                    .font(.custom("Roboto-Medium", size: 10.0))
                                        .foregroundColor(Color(red: 34.0 / 255.0, green: 38.0 / 255.0, blue: 38.0 / 255.0))
                                        .multilineTextAlignment(.center)
                                }
                            }
                            
                            ForEach(arrMenus, id: \.id) { menu in
                                InfoCard(width: max(0, geometry.size.width-50), menu: menu, isForProfile: true)
                                    .onTapGesture {
                                        switch menu.id {
                                        case 1:
                                            showAccountView.toggle()
                                        case 2:
                                            showNotificationView.toggle()
                                        case 3:
                                            showBookmarkView.toggle()
                                        case 4:
                                            showSupportView.toggle()
                                        case 5:
                                            showLogoutAlert.toggle()
                                        case 6:
                                            showDeleteAlert.toggle()
                                        default:
                                            break
                                        
                                        }
                                    }
                            }
                                
                        }
                        .padding(.horizontal, 40)
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
            .navigationDestination(isPresented: $showAccountView) {
                if showAccountView {
                    AccountView()
                }
            }
            .navigationDestination(isPresented: $showNotificationView) {
                if showNotificationView {
                    NotificationsView()
                }
            }
            .navigationDestination(isPresented: $showBookmarkView, destination: {
                if showBookmarkView {
                    BookMarksView()
                }
            })
            .navigationDestination(isPresented: $showSupportView) {
                if showSupportView {
                    SupportView(onCompleteDismiss: {
                        showSupportView = false
                    })
                }
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("NO", role: .cancel) { }
                
                Button("Yes") {
                    // Clear user data
                    appUserDefaults.userData = nil
                    
                    // Post notification to ContentView to handle navigation
                    // This avoids navigationDestination warnings when NavigationStack is removed
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name(NotificationNames.popToLogin), object: nil)
                        NavigationCoordinator.shared.shouldNavigateToLogin = true
                    }
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .alert("Delete Account", isPresented: $showDeleteAlert) {
                Button("NO", role: .cancel) { }
                
                Button("Yes") {
                    viewModel.deleteAccount()
                }
            } message: {
                Text("Are you sure you want to delete your account?")
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
                isMenuSelected = false
            }),
        ]
    }
}

#Preview {
    ProfileView()
}

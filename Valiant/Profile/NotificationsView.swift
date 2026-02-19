//
//  NotificationsView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 11/02/26.
//

import SwiftUI

struct NotificationsView: View {
    
    @StateObject var viewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isMenuSelected = false
    @State private var showDashboardView = false
    @State private var showAlertListView = false
    @State private var showCalendarView = false
    @State private var showMessageView = false
    @State private var showRequestGuidRepView = false
    @State private var showAdditionalInfoView = false
    @State private var showProfileView = false
    @State private var selectedNotification: NotificationItem?
    @State private var showNotificationDetail = false
    


    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        Text("Notifications")
                            .font(.custom("HelveticaNeue-Bold", size: 18.0))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(Array(viewModel.notifications.enumerated()), id: \.element.id) { index, notification in
                            if index == 0 {
                                LatestNotificationCard(width: max(0, geometry.size.width-60), notification: notification)
                                    .onTapGesture {
                                        selectedNotification = notification
                                        showNotificationDetail = true
                                    }
                            } else{
                                NotificationCard(width: max(0, geometry.size.width-60), notification: notification)
                                    .onTapGesture {
                                        if !(notification.isRead ?? false) {
                                            viewModel.markNotificationAsRead(notificationId: notification.id ?? 0)
                                        }
                                        selectedNotification = notification
                                        showNotificationDetail = true
                                    }
                            }
                        }
                        
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 30)

                }
                .background(.white)
                
                // Floating Menu Button
                FloatingMenuActionButton(
                    isSelected: $isMenuSelected,
                    floatingMenuItems: generateFloatingMenuItems()
                )
                .padding(.trailing, 8)
                .padding(.bottom, 30)
                
                // MARK: - Notification Popup
                if let notification = selectedNotification {
                    NotificationPopupView(
                        notification: notification,
                        isPresented: Binding(
                            get: { selectedNotification != nil },
                            set: { if !$0 { selectedNotification = nil } }
                        )
                    )
                }
            }
            .task {
                await Task { @MainActor in
                    viewModel.getAllNotifications()
                }.value
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
            .navigationDestination(isPresented: $showMessageView) {
                if showMessageView {
                    PresidentMessageListView()
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
                showAdditionalInfoView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_user", buttonAction: {
                showProfileView = true
                isMenuSelected = false
            }),
        ]
    }
}

#Preview {
    NotificationsView()
}

struct NotificationPopupView: View {
    let notification: NotificationItem
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            // Popup content
            VStack(alignment: .leading, spacing: 16) {
                Text(notification.title ?? "")
                    .font(.custom("HelveticaNeue-Medium", size: 18.0))
                    .foregroundColor(Color(hex: "#17393b"))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(notification.message ?? "")
                    .font(.custom("HelveticaNeue-light", size: 14.0))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                let scheduledDate = appSharedData.convertDateFormatFromForDate(fromFormat: "yyyy-MM-dd", toFormat: "MMM dd, yyyy", stringDate: notification.scheduledDate ?? "2026-01-05")
                let scheduledTime = appSharedData.convertDateFormatFromForDate(fromFormat: "HH:MM:SS", toFormat: "hh:mm a", stringDate: notification.scheduledDate ?? "10:00:00")
                Text("\(scheduledDate) \(scheduledTime)")
                    .font(.custom("Roboto-light", size: 12.0))
                    .foregroundColor(Color(white: 112.0 / 255.0))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("CLOSE")
                            .font(.custom("HelveticaNeue-Medium", size: 14))
                            .foregroundColor(Color(hex: "#17393b"))
                            .frame(width: 100)
                            .padding(.vertical, 20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(.blue, lineWidth: 1)
                            )
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(hex: "#e2e7f1"), location: 0.0),
                    Gradient.Stop(color: Color(hex: "#c4cde2"), location: 1.0)],
                startPoint: .bottom,
                endPoint: .bottomLeading))

        }
    }
}

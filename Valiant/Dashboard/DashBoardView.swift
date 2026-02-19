//
//  DashBoardView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 04/02/26.
//

import SwiftUI

struct DashBoardView: View {
    // Sample data for alerts - replace with actual data model
    @StateObject var viewModel = DashBoardViewModel()
    @State private var selectedAlertId = 0
    @State private var selectedEventId = 0
    @State private var selectedMessageId = 0
    @State private var isMenuSelected = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack(alignment: .bottomTrailing) {
                    // Scrollable content
                    ScrollView {
                        VStack(spacing: 8) {
                            // Latest SPOG Alerts Section
                            latestSPOGAlertsSection
                                .background(Color(white: 244.0 / 255.0))
                                .cornerRadius(2.0)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                            
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: max(0, geometry.size.width - 60), height: 190.0)
                                        .background(LinearGradient(
                                            stops: [
                                                Gradient.Stop(color: Color(red: 226.0 / 255.0, green: 231.0 / 255.0, blue: 241.0 / 255.0), location: 0.0),
                                                Gradient.Stop(color: Color(red: 196.0 / 255.0, green: 205.0 / 255.0, blue: 226.0 / 255.0), location: 1.0)],
                                            startPoint: .bottom,
                                            endPoint: .bottomLeading))
                                        .cornerRadius(2)
                                    
                                    upcomingSPOGEventsSection
                                        .padding(.horizontal, 20)
                                }
                                
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: max(0, geometry.size.width - 60), height: 190.0)
                                        .background(LinearGradient(
                                            stops: [
                                                Gradient.Stop(color: Color(red: 226.0 / 255.0, green: 231.0 / 255.0, blue: 241.0 / 255.0), location: 0.0),
                                                Gradient.Stop(color: Color(red: 196.0 / 255.0, green: 205.0 / 255.0, blue: 226.0 / 255.0), location: 1.0)],
                                            startPoint: .bottom,
                                            endPoint: .bottomLeading))
                                        .cornerRadius(2)
                                    
                                    upcomingPresidentsMessageSection
                                        .padding(.horizontal, 20)
                                }
                            }
                            .frame(height: 380.0)
                            
                            MenuGridView(screenWidth: geometry.size.width) { index in
                                switch index {
                                case 1:
                                    viewModel.showAlertView.toggle()
                                case 2:
                                    viewModel.showCalendarView.toggle()
                                case 3:
                                    viewModel.showMessageView.toggle()
                                case 4:
                                    viewModel.showDocumentView.toggle()
                                case 5:
                                    viewModel.showRequestGuidRepView.toggle()
                                case 6:
                                    viewModel.showContactSpogView.toggle()
                                default:
                                    break
                                }
                            }
                            .background(Color(white: 244.0 / 255.0))
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                            
                        }
                        .padding(.horizontal, 10)

                    }
                    
                    // Floating Menu Button
                    FloatingMenuActionButton(
                        isSelected: $isMenuSelected,
                        floatingMenuItems: generateFloatingMenuItems()
                    )
                    .padding(.trailing, 8)
                    .padding(.bottom, 30)
                }
            }
            .background(.white)
            .navigationBarBackButtonHidden()
            .toolbar {
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
            .task {
                // Add small delay to ensure view is fully loaded and any previous loading indicators are cleared
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                await Task { @MainActor in
                    // Ensure loading indicator is hidden before starting new request
                    LoadingIndicatorView.hide()
                    viewModel.getSpogHomeData()
                }.value
            }
            // Navigation destinations
            .navigationDestination(isPresented: $viewModel.showAlertView) {
                if viewModel.showAlertView {
                    AlertListView()
                }
            }
            .navigationDestination(isPresented: $viewModel.showAlertDetailView) {
                if viewModel.showAlertDetailView {
                    AlertDetailView(alertId: selectedAlertId)
                }
            }
            .navigationDestination(isPresented: $viewModel.showCalendarView) {
                if viewModel.showCalendarView {
                    CalendarListView()
                }
            }
            .navigationDestination(isPresented: $viewModel.showEventView) {
                if viewModel.showEventView {
                    EventListView()
                }
            }
            .navigationDestination(isPresented: $viewModel.showEventDetailView) {
                if viewModel.showEventDetailView {
                    EventDetailView(eventId: selectedEventId)
                }
            }
            .navigationDestination(isPresented: $viewModel.showMessageView) {
                if viewModel.showMessageView {
                    PresidentMessageListView()
                }
            }
            .navigationDestination(isPresented: $viewModel.showMessageDetailView) {
                if viewModel.showMessageDetailView {
                    MessageDetailView(messageId: selectedMessageId)
                }
            }
            .navigationDestination(isPresented: $viewModel.showDocumentView) {
                if viewModel.showDocumentView {
                    DocumentListView()
                }
            }
            .navigationDestination(isPresented: $viewModel.showRequestGuidRepView) {
                if viewModel.showRequestGuidRepView {
                    RequestGuidRep(onCompleteDismiss: {
                        viewModel.showRequestGuidRepView = false
                    })
                }
            }
            .navigationDestination(isPresented: $viewModel.showContactSpogView) {
                if viewModel.showContactSpogView {
                    ContactSpogView(onCompleteDismiss: {
                        viewModel.showContactSpogView = false
                    })
                }
            }
            .navigationDestination(isPresented: $viewModel.showAdditionalInfoView) {
                if viewModel.showAdditionalInfoView {
                    AdditionalInfoView()
                }
            }
            .navigationDestination(isPresented: $viewModel.showProfileView) {
                if viewModel.showProfileView {
                    ProfileView()
                }
            }
        }
    }
    
    // MARK: - Latest SPOG Alerts Section
    private var latestSPOGAlertsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Title
            Text("LATEST SPOG ALERTS")
                .font(.custom("HelveticaNeue-Regular", size: 14.0))
                .foregroundColor(Color(white: 112.0 / 255.0))
                .multilineTextAlignment(.leading)
            
            // Horizontal scrolling cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.arrSpogAlerts) { alert in
                        SPOGAlertCard(alert: alert)
                            .onTapGesture {
                                selectedAlertId = alert.id
                                viewModel.showAlertDetailView = true
                            }
                    }
                    
                }
                .padding(.horizontal, 4)
            }
            
            // See All Alerts Link
            Button(action: {
                viewModel.showAlertView.toggle()
            }) {
                Text("SEE ALL ALERTS")
                    .font(.custom("Roboto-Regular", size: 14.0))
                    .foregroundColor(Color("seeAllColor"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)

    }
    
    // MARK: - Upcoming SPOG Events Section
    private var upcomingSPOGEventsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section Title
            Text("UPCOMING SPOG CALENDAR EVENTS")
                .font(.custom("HelveticaNeue-Regular", size: 14.0))
                .foregroundColor(Color(white: 112.0 / 255.0))
                .multilineTextAlignment(.leading)
            
            // Horizontal scrolling cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.arrSpogEvents) { event in
                        EventCard(event: event)
                            .onTapGesture {
                                selectedEventId = event.id
                                viewModel.showEventDetailView = true
                            }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            // See All Alerts Link
            Button(action: {
                viewModel.showEventView.toggle()
            }) {
                Text("SEE ALL CALENDAR EVENTS")
                    .font(.custom("Roboto-Regular", size: 14.0))
                    .foregroundColor(Color("seeAllColor"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)

    }
    
    // MARK: - Latest SPOG Alerts Section
    private var upcomingPresidentsMessageSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section Title
            Text("LATEST PRESIDENT’S MESSAGE")
                .font(.custom("HelveticaNeue-Regular", size: 14.0))
                .foregroundColor(Color(white: 112.0 / 255.0))
                .multilineTextAlignment(.leading)
            
            // Horizontal scrolling cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.arrPresidentsMessages) { message in
                        MessageCard(message: message)
                            .onTapGesture {
                                selectedMessageId = message.id
                                viewModel.showMessageDetailView = true
                            }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            // See All Alerts Link
            Button(action: {
                viewModel.showMessageView.toggle()
            }) {
                Text("SEE ALL PRESIDENT’S MESSAGE")
                    .font(.custom("Roboto-Regular", size: 14.0))
                    .foregroundColor(Color("seeAllColor"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)

    }
    
    // MARK: - Floating Menu Items
    private func generateFloatingMenuItems() -> [FloatingMenuItem] {
        return [
            .init(iconName: "ic_home", buttonAction: {
                // Already on dashboard, just close menu
                isMenuSelected = false
            }),
            .init(iconName: "ic_bell", buttonAction: {
                viewModel.showAlertView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_calendar", buttonAction: {
                viewModel.showCalendarView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_president_message", buttonAction: {
                viewModel.showMessageView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_contact_shortcut", buttonAction: {
                viewModel.showRequestGuidRepView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_more", buttonAction: {
                viewModel.showAdditionalInfoView = true
                isMenuSelected = false
            }),
            .init(iconName: "ic_user", buttonAction: {
                // Add user actions here
                viewModel.showProfileView = true
                isMenuSelected = false
            }),
        ]
    }
}

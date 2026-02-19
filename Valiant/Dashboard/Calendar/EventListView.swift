//
//  EventListView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 08/02/26.
//

import SwiftUI

struct EventListView: View {
    
    @StateObject var viewModel = EventViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedEventId = 0
    @State private var isMenuSelected = false
    @State private var showDashboardView = false
    @State private var showAlertListView = false
    @State private var showCalendarView = false
    @State private var showMessageView = false
    @State private var showRequestGuidRepView = false
    @State private var showAdditionalInfoView = false
    @State private var showProfileView = false
    
    // Filtered alerts based on search text
    private var filteredEvents: [SpogEvent] {
        if searchText.isEmpty {
            return viewModel.arrSpogEvents
        } else {
            return viewModel.arrSpogEvents.filter { event in
                event.title.localizedCaseInsensitiveContains(searchText) ||
                event.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                
                HStack(spacing: 16) {
                    Text("SPOG Events")
                        .font(.custom("HelveticaNeue-Bold", size: 22.0))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 8)
                
                // Search Bar
                searchBarSection
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Color.white)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Show first event as LatestEventCard
                        if let firstEvent = filteredEvents.first {
                            LatestEventCard(width: geometry.size.width-32, event: firstEvent, viewModel: viewModel)
                                    .onTapGesture {
                                    self.selectedEventId = firstEvent.id
                                    self.viewModel.showEventDetailView.toggle()
                                    }
                            }
                        
                        // Show remaining events in grid
                        if filteredEvents.count > 1 {
                            let remainingEvents = Array(filteredEvents.dropFirst())
                            let columns = [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ]
                            
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(remainingEvents) { event in
                                    EventListItemCard(event: event, screenWidth: (geometry.size.width - 44) / 2, showDetails: true, viewModel: viewModel)
                                    .onTapGesture {
                                            self.selectedEventId = event.id
                                            self.viewModel.showEventDetailView.toggle()
                                        }
                                    }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 30)
                        }
                    }
                    .padding(.horizontal, 16)
                }
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
            .task {
                await Task { @MainActor in
                    viewModel.getSpogEvents()
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
            .navigationDestination(isPresented: $viewModel.showEventDetailView) {
                if viewModel.showEventDetailView {
                    EventDetailView(eventId: self.selectedEventId)
                }
            }
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
    
    // MARK: - Search Bar Section
    private var searchBarSection: some View {
        HStack(spacing: 12) {
            
            TextField("Search events...", text: $searchText)
                .font(.custom("HelveticaNeue-Regular", size: 14))
                .foregroundColor(Color(white: 112.0 / 255.0))
                .padding(.leading, 8)
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Color(white: 112.0 / 255.0))

        }
        .background(Color(white: 244.0 / 255.0))
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
    EventListView()
}

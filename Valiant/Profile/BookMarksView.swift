//
//  BookMarksViewView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 13/02/26.
//

import SwiftUI

struct BookMarksView: View {
    
    @StateObject var viewModel = ProfileViewModel()
    @StateObject var eventViewModel = EventViewModel()
    @StateObject var docViewModel = DocumentViewModel()
    @StateObject var messViewModel = MessageViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isMenuSelected = false
    @State private var showDashboardView = false
    @State private var showAlertListView = false
    @State private var showCalendarView = false
    @State private var showMessageView = false
    @State private var showRequestGuidRepView = false
    @State private var showAdditionalInfoView = false
    @State private var showProfileView = false
    
    @State private var selectedIndex = 0
    @State private var selectedEventId = 0
    @State private var selectedDocumentId = 0
    @State private var selectedMessageId = 0

    

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        Text("Bookmark")
                            .font(.custom("HelveticaNeue-Bold", size: 18.0))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 5) {
                            Button(action: {
                                selectedIndex = 0
                            }) {
                                Text("Event")
                                    .font(.custom("HelveticaNeue-Medium", size: 10))
                                    .foregroundColor(Color(hex: "#16393b"))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(selectedIndex == 0 ? Color(hex: "#c5cde2") : Color(hex: "#f4f4f4"))
                            }
                            
                            Button(action: {
                                selectedIndex = 1
                            }) {
                                Text("SPOG Documents")
                                    .font(.custom("HelveticaNeue-Medium", size: 10))
                                    .foregroundColor(Color(hex: "#16393b"))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(selectedIndex == 1 ? Color(hex: "#c5cde2") : Color(hex: "#f4f4f4"))
                            }
                            
                            Button(action: {
                                selectedIndex = 2
                            }) {
                                Text("President Messages")
                                    .font(.custom("HelveticaNeue-Medium", size: 10))
                                    .foregroundColor(Color(hex: "#16393b"))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(selectedIndex == 2 ? Color(hex: "#c5cde2") : Color(hex: "#f4f4f4"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        if selectedIndex == 0 {
                            let columns = [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ]
                            
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(viewModel.arrSpogEvents) { event in
                                    EventListItemCard(event: event, screenWidth: (geometry.size.width - 44) / 2, showDetails: true, viewModel: eventViewModel)
                                    .onTapGesture {
                                            self.selectedEventId = event.id
                                            self.eventViewModel.showEventDetailView.toggle()
                                        }
                                    }
                            }
                        }
                        if selectedIndex == 1 {
                            ForEach(Array(viewModel.arrDocuments.enumerated()), id: \.element.id) { index, document in
                                DocumentCard(width: geometry.size.width-32, document: document, viewModel: docViewModel)
                                    .onTapGesture {
                                        self.selectedDocumentId = document.id
                                        self.docViewModel.showMessageDetailView.toggle()
                                    }
                            }
                        }
                        
                        if selectedIndex == 2 {
                            ForEach(Array(viewModel.arrPresidentsMessage.enumerated()), id: \.element.id) { index, message in
                                OtherMessageCard(message: message, width: geometry.size.width-32, viewModel: messViewModel)
                                    .onTapGesture {
                                        self.selectedMessageId = message.id
                                        self.messViewModel.showMessageDetailView.toggle()
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
                
            }
            .task {
                await Task { @MainActor in
                    viewModel.getBookmarkList()
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
            .navigationDestination(isPresented: $eventViewModel.showEventDetailView) {
                if eventViewModel.showEventDetailView {
                    EventDetailView(eventId: self.selectedEventId)
                }
            }
            .navigationDestination(isPresented: $docViewModel.showMessageDetailView) {
                if docViewModel.showMessageDetailView {
                    DocumentDetailView(documentId: selectedDocumentId)
                }
            }
            .navigationDestination(isPresented: $messViewModel.showMessageDetailView) {
                if messViewModel.showMessageDetailView {
                    MessageDetailView(messageId: self.selectedMessageId)
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
    BookMarksView()
}

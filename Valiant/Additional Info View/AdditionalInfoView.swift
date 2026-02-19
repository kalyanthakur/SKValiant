//
//  AdditionalInfoView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 10/02/26.
//

import SwiftUI

struct AdditionalInfoView: View {
    
    @ObservedObject var viewModel = AdditionalInfoViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isMenuSelected = false
    @State private var showDashboardView = false
    @State private var showAlertListView = false
    @State private var showCalendarView = false
    @State private var showEventListView = false
    @State private var showMessageView = false
    @State private var showSPOGSocialMediaView = false
    @State private var showDocumentView = false
    @State private var showContactSpogView = false
    @State private var showFallenOfficersView = false
    @State private var showOlympiaLegislationView = false
    @State private var showSaucierScholarshipView = false
    @State private var showVotePostView = false
    @State private var showRequestGuidRepView = false
    @State private var showProfileView = false
    
    let arrMenus = [
        MenuItems(id: 1, name: "SPOG Social Media", icon: "ic_solial_media"),
        MenuItems(id: 2, name: "SPOG Documents", icon: "ic_document_spog"),
        MenuItems(id: 3, name: "Contact SPOG", icon: "ic_spog_contact"),
        MenuItems(id: 4, name: "Fallen Officers", icon: "ic_fallen_officers"),
        MenuItems(id: 5, name: "Olympia Legislation", icon: "ic_olympia_legislation"),
        MenuItems(id: 6, name: "Saucier Scholarship", icon: "ic_saucier_scholarship"),
        MenuItems(id: 7, name: "Vote", icon: "ic_vote")
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                
                HStack(spacing: 16) {
                    Text("Additional Info")
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
                            InfoCard(width: max(0, geometry.size.width-32), menu: menu, isForProfile: false)
                                .onTapGesture {
                                    switch menu.id {
                                    case 1:
                                        showSPOGSocialMediaView = true
                                    case 2:
                                        showDocumentView = true
                                    case 3:
                                        showContactSpogView = true
                                    case 4:
                                        showFallenOfficersView = true
                                    case 5:
                                        showOlympiaLegislationView = true
                                    case 6:
                                        showSaucierScholarshipView = true
                                    case 7:
                                        showVotePostView = true
                                    default:
                                        break
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
            .navigationDestination(isPresented: $showSPOGSocialMediaView) {
                if showSPOGSocialMediaView {
                    SPOGSocialMediaView()
                }
            }
            .navigationDestination(isPresented: $showFallenOfficersView) {
                if showFallenOfficersView {
                    FallenOfficersView()
                }
            }
            .navigationDestination(isPresented: $showOlympiaLegislationView) {
                if showOlympiaLegislationView {
                    OlympiaLegislationView()
                }
            }
            .navigationDestination(isPresented: $showSaucierScholarshipView) {
                if showSaucierScholarshipView {
                    SaucierScholarshipView()
                }
            }
            .navigationDestination(isPresented: $showVotePostView) {
                if showVotePostView {
                    VotePostView()
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
    AdditionalInfoView()
}

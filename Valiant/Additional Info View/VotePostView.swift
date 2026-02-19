//
//  VotePostView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 11/02/26.
//

import SwiftUI

struct VotePostView: View {
    
    @StateObject var viewModel = AdditionalInfoViewModel()
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
    @State private var showProfileView = false

    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                
                    if let data = viewModel.votePDF {
                        HStack(spacing: 16) {
                            Text(data.title)
                                .font(.custom("HelveticaNeue-Bold", size: 16.0))
                                .foregroundColor(Color(red: 34.0 / 255.0, green: 38.0 / 255.0, blue: 38.0 / 255.0))
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 8)
                        
                        WebView(urlString: data.pdfUrl)
                    } else {
                        // Loading state - takes up space to prevent menu from appearing on top
                        Spacer()
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Spacer()
                    }
                }
                .background(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                FloatingMenuActionButton(
                    isSelected: $isMenuSelected,
                    floatingMenuItems: generateFloatingMenuItems()
                )
                .padding(.trailing, 8)
                .padding(.bottom, 30)
            }
            .task {
                await Task { @MainActor in
                    viewModel.getVotePost()
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
    VotePostView()
}

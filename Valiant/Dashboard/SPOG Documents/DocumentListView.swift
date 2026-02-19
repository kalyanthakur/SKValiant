//
//  DocumentListView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 08/02/26.
//

import SwiftUI

struct DocumentListView: View {
    
    @StateObject var viewModel = DocumentViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedDocumentId = 0
    @State private var isMenuSelected = false
    @State private var showDashboardView = false
    @State private var showAlertListView = false
    @State private var showCalendarView = false
    @State private var showEventListView = false
    @State private var showMessageView = false
    @State private var showRequestGuidRepView = false
    @State private var showAdditionalInfoView = false
    @State private var showProfileView = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                
                HStack(spacing: 16) {
                    Text("Official SPOG Documents")
                        .font(.custom("HelveticaNeue-Bold", size: 22.0))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 8)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(Array(viewModel.arrDocuments.enumerated()), id: \.element.id) { index, document in
                            if index == 0 {
                                FeatureCard(width: geometry.size.width-32, document: document, viewModel: viewModel)
                                    .onTapGesture {
                                        self.selectedDocumentId = document.id
                                        self.viewModel.showMessageDetailView.toggle()
                                    }
                            } else {
                                DocumentCard(width: geometry.size.width-32, document: document, viewModel: viewModel)
                                    .onTapGesture {
                                        self.selectedDocumentId = document.id
                                        self.viewModel.showMessageDetailView.toggle()
                                    }
                            }
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
                    viewModel.getSpogDocuments()
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
            .navigationDestination(isPresented: $viewModel.showMessageDetailView) {
                if viewModel.showMessageDetailView {
                    DocumentDetailView(documentId: selectedDocumentId)
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
    DocumentListView()
}

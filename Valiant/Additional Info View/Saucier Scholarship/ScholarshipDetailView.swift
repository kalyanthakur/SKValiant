//
//  ScholarshipDetailView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 11/02/26.
//

import SwiftUI

struct ScholarshipDetailView: View {
    
    @StateObject var viewModel = AdditionalInfoViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var scholarshipId: Int = 0
    @State private var isMenuSelected = false
    @State private var showDashboardView = false
    @State private var showAlertListView = false
    @State private var showCalendarView = false
    @State private var showEventListView = false
    @State private var showMessageView = false
    @State private var showDocumentListView = false
    @State private var showAdditionalInfoView = false
    @State private var showRequestGuidRepView = false
    @State private var showProfileView = false

    
    init(scholarshipId:Int) {
        self._scholarshipId = State(initialValue: scholarshipId)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                                
                    Text("\(viewModel.scholarship?.title ?? "Saucier Scholarship")")
                    .font(.custom("HelveticaNeue-Bold", size: 18.0))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)


                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            if let scholarshipDetail = viewModel.scholarship {
                                if !scholarshipDetail.coverImg.isEmpty {
                                    let imageURL = appSharedData.constructImageURL(from: scholarshipDetail.coverImg)
                                    AsyncImage(url: URL(string: imageURL)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 80, height: 80)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .cornerRadius(8)
                                                .frame(width: geometry.size.width-70, height: geometry.size.width-120)
                                        case .failure:
                                            // Fallback to SPOG logo if image fails to load
                                            Image("SPOG_logo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 80, height: 80)
                                        @unknown default:
                                            Image("SPOG_logo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 80, height: 80)
                                        }
                                    }
                                }
                                
                                HTMLText(html: scholarshipDetail.title, color: "#2f2f2f", fontSize: 14)
                                
                                HTMLText(html: scholarshipDetail.description, color: "#7e8492", fontSize: 10)

                            }
                        }
                        .padding(.horizontal, 16)
                    }
                
                }
                .padding(.horizontal, 20)
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
                    viewModel.getSaucierScholarshipPostsDetailsById(scholarshipId: scholarshipId)
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
            .navigationDestination(isPresented: $showDocumentListView) {
                if showDocumentListView {
                    DocumentListView()
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

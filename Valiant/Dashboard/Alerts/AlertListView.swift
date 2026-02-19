//
//  AlertListView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 06/02/26.
//

import SwiftUI

struct AlertListView: View {
    @StateObject var viewModel = AlertViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedAlertId = 0
    @State private var isMenuSelected = false
    @State private var showDashboardView = false
    @State private var showCalendarView = false
    @State private var showMessageView = false
    @State private var showRequestGuidRepView = false
    @State private var showAdditionalInfoView = false
    @State private var showProfileView = false

    // Filtered alerts based on search text
    private var filteredAlerts: [SpogAlert] {
        if searchText.isEmpty {
            return viewModel.arrAllAlerts
        } else {
            return viewModel.arrAllAlerts.filter { alert in
                alert.title.localizedCaseInsensitiveContains(searchText) ||
                alert.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                
                HStack(spacing: 0) {
                    Text("SPOG")
                        .font(.custom("HelveticaNeue-Bold", size: 22.0))
                        .foregroundColor(Color(white: 112.0 / 255.0))
                        .multilineTextAlignment(.leading)
                    
                    LottieView(name: "siren_alert")
                            .frame(width: 40, height: 40)
                            .padding(.bottom, 8)
                    
                    Text("ALERTS")
                        .font(.custom("HelveticaNeue-Bold", size: 22.0))
                        .foregroundColor(Color(white: 112.0 / 255.0))
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 8)
                
                // Search Bar
                searchBarSection
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Color.white)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(Array(filteredAlerts.enumerated()), id: \.element.id) { index, alert in
                            if index == 0 {
                                LatestAlertCard(width: geometry.size.width-32, alert: alert)
                                    .onTapGesture {
                                        selectedAlertId = alert.id
                                        viewModel.showAlertDetailView = true
                                    }
                            }
                            else {
                                OtherCard(alert: alert, width: geometry.size.width-32)
                                    .onTapGesture {
                                        selectedAlertId = alert.id
                                        viewModel.showAlertDetailView = true
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
                    viewModel.getSpogAlerts()
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
            .navigationDestination(isPresented: $viewModel.showAlertDetailView) {
                if viewModel.showAlertDetailView {
                    AlertDetailView(alertId: selectedAlertId)
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
            .navigationDestination(isPresented: $showDashboardView) {
                if showDashboardView {
                    DashBoardView()
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
            
            TextField("Search alerts...", text: $searchText)
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
                // Already on alerts, just close menu
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
    AlertListView()
}

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {

    let name: String
    var loopMode: LottieLoopMode = .loop

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

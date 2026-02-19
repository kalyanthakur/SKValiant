//
//  SupportView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 13/02/26.
//

import SwiftUI

struct SupportView: View {
    
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
    
    @State private var name: String = ""
    @State private var message: String = ""

    let onCompleteDismiss: (() -> Void)?
    
    init(onCompleteDismiss: (() -> Void)? = nil) {
        self.onCompleteDismiss = onCompleteDismiss
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        Text("App Support")
                            .font(.custom("HelveticaNeue-Bold", size: 18.0))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Use this form for technical support in the app.")
                            .font(.custom("HelveticaNeue-Light", size: 10.0))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 24) {
                            
                            // Name
                            FormTextField(title: "Name", text: $name)
                            
                            // Message
                            FormTextView(title: "Message", text: $message)
                            
                            
                            // Submit button
                            HStack {
                                Spacer()
                                Button(action: {
                                    // Handle submit action
                                        submitForm()
                                }) {
                                    Text("Submit")
                                        .font(.custom("HelveticaNeue-Medium", size: 14))
                                        .foregroundColor(.white)
                                            .frame(width: 150)
                                        .padding(.vertical, 14)
                                        .background(Color(red: 0.1, green: 0.2, blue: 0.4))
                                        .cornerRadius(4)
                                    }
                                Spacer()
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 32)
                        }
                        .padding(.top, 30)
                        
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
            .navigationDestination(isPresented: $viewModel.showSuccess) {
                RequestSuccessView(onDismiss: {
                    // First dismiss RequestSuccessView
                    viewModel.showSuccess = false
                    // Then dismiss RequestGuidRep
                    dismiss()
                    // Finally dismiss from Dashboard
                    onCompleteDismiss?()
                }, title: "Message submitted", description: createAttributedString())
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
    private func submitForm() {
        let status = viewModel.validSubmitForm(name: name, message: message)
        
        if status {
            viewModel.appSupport(name: name, message: message)
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
    
    private func createAttributedString() -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "Thank you for submitting your message. We'll respond ASAP. If your situation is urgent, please call SPOG directly (206) 767-1150.", attributes: [
          .font: UIFont(name: "Roboto-Regular", size: 14.0)!,
          .foregroundColor: UIColor(white: 112.0 / 255.0, alpha: 1.0)
        ])
        return attributedString
    }
}

#Preview {
    SupportView()
}

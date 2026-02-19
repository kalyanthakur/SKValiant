//
//  ContactSpogView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 09/02/26.
//

import SwiftUI

struct ContactSpogView: View {
    
    @ObservedObject var viewModel = ContactViewModel()
    @Environment(\.dismiss) private var dismiss
    let onCompleteDismiss: (() -> Void)?
    
    init(onCompleteDismiss: (() -> Void)? = nil) {
        self.onCompleteDismiss = onCompleteDismiss
    }
    @State private var isMenuSelected = false
    @State private var showDashboardView = false
    @State private var showAlertListView = false
    @State private var showCalendarView = false
    @State private var showEventListView = false
    @State private var showMessageView = false
    @State private var showAdditionalInfoView = false
    @State private var showRequestGuidRepView = false
    @State private var showProfileView = false
    @State private var name: String = ""
    @State private var serial: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var message: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                
                HStack(spacing: 16) {
                    Text("Contact SPOG")
                        .font(.custom("HelveticaNeue-Bold", size: 16.0))
                        .foregroundColor(Color(red: 34.0 / 255.0, green: 38.0 / 255.0, blue: 38.0 / 255.0))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 8)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // Name
                        FormTextField(title: "Name", text: $name)
                        
                        // Serial
                        FormTextField(title: "Serial", text: $serial)
                        
                        // Phone
                        FormTextField(title: "Phone", text: $phone, keyboardType: .phonePad)
                        
                        // Non-Seattle Gov email address
                        FormTextField(title: "Non-Seattle Gov email address", text: $email, keyboardType: .emailAddress)
                        
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
                    .padding(.horizontal, 32)
                }
                .padding(.top, 30)
                
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
    
    private func submitForm() {
        let status = viewModel.validSubmitForm(name: name, serial: serial, phone: phone, email: email, message: message)
        
        if status {
            viewModel.contactSpog(name: name, serial: serial, phone: phone, email: email, message:message)
        }
    }
    private func createAttributedString() -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "Thank you for submitting your message. We'll respond ASAP. If your situation is urgent, please call SPOG directly (206) 767-1150.", attributes: [
          .font: UIFont(name: "Roboto-Regular", size: 14.0)!,
          .foregroundColor: UIColor(white: 112.0 / 255.0, alpha: 1.0)
        ])
        return attributedString
    }
}

// MARK: - Form Text View (Multiline)
struct FormTextView: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                // TextEditor
                TextEditor(text: $text)
                    .font(.custom("HelveticaNeue-Regular", size: 14))
                    .foregroundColor(.black)
                    .frame(minHeight: 120)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                
                // Placeholder text (on top)
                if text.isEmpty {
                    Text(title)
                        .font(.custom("HelveticaNeue-Regular", size: 14))
                        .foregroundColor(Color(white: 200.0 / 255.0))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color(white: 112.0 / 255.0), lineWidth: 1)
            )
        }
    }
}

#Preview {
    ContactSpogView()
}

//
//  RequestGuidRep.swift
//  Valiant
//
//  Created by Kalyan Thakur on 09/02/26.
//

import SwiftUI
import UIKit

struct RequestGuidRep: View {
    
    @ObservedObject var viewModel = RequestGuidViewModel()
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
    @State private var dateOfInterview: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showDatePicker: Bool = false
    @State private var timeOfInterview: String = ""
    @State private var selectedTime: Date = Date()
    @State private var showTimePicker: Bool = false
    @State private var investigator: String = ""
    @State private var nameOfWitness: String = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                
                HStack(spacing: 16) {
                    Text("Request a Guid Rep")
                        .font(.custom("HelveticaNeue-Bold", size: 16.0))
                        .foregroundColor(Color(red: 34.0 / 255.0, green: 38.0 / 255.0, blue: 38.0 / 255.0))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                .padding(.horizontal, 40)
                .padding(.vertical, 8)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Instructional text
                        AttributedTextView(attributedString: createAttributedString())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                        
                        // Name
                        FormTextField(title: "Name", text: $name)
                        
                        // Serial
                        FormTextField(title: "Serial", text: $serial)
                        
                        // Phone
                        FormTextField(title: "Phone", text: $phone, keyboardType: .phonePad)
                        
                        // Non-Seattle Gov email address
                        FormTextField(title: "Non-Seattle Gov email address", text: $email, keyboardType: .emailAddress)
                        
                        // Date of Interview
                        DatePickerField(title: "Date of Interview", date: $selectedDate, text: $dateOfInterview, showPicker: $showDatePicker)
                        
                        VStack {
                            // Time of Interview
                            TimePickerField(title: "Time of Interview", time: $selectedTime, text: $timeOfInterview, showPicker: $showTimePicker)
                            
                            // Instructional text for date
                            Text("If your interview is in less than 24 hours, please call SPOG directly.")
                                .font(.custom("Roboto-Regular", size: 10.0))
                                .foregroundColor(Color(white: 112.0 / 255.0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Investigator
                        FormTextField(title: "Investigator", text: $investigator)
                        
                        // Name of Witness
                        FormTextField(title: "Name of Witness", text: $nameOfWitness)
                        
                        // Submit button
                        Button(action: {
                            // Handle submit action
                            submitForm()
                        }) {
                            Text("Submit")
                                .font(.custom("HelveticaNeue-Medium", size: 14))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.1, green: 0.2, blue: 0.4))
                                .cornerRadius(4)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                    }
                    .padding(.horizontal, 32)
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
            .sheet(isPresented: $showDatePicker) {
                PickerSheet(
                    selectedDate: $selectedDate,
                    text: $dateOfInterview,
                    showPicker: $showDatePicker,
                    pickerType: .date
                )
            }
            .sheet(isPresented: $showTimePicker) {
                PickerSheet(
                    selectedDate: $selectedTime,
                    text: $timeOfInterview,
                    showPicker: $showTimePicker,
                    pickerType: .time
                )
            }
            .navigationDestination(isPresented: $viewModel.showSuccess) {
                RequestSuccessView(onDismiss: {
                    // First dismiss RequestSuccessView
                    viewModel.showSuccess = false
                    // Then dismiss RequestGuidRep
                    dismiss()
                    // Finally dismiss from Dashboard
                    onCompleteDismiss?()
                }, title: "Request submitted", description: successAttributedString())
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
                // Already on RequestGuidRep, just close menu
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
        let attributedString = NSMutableAttributedString(string: "For last minute requests, call SPOG directly (206) 767-1150.\nOtherwise, please fill out the form and we'll be in touch ASAP.", attributes: [
            .font: UIFont(name: "Roboto-Regular", size: 10.0)!,
            .foregroundColor: UIColor(white: 112.0 / 255.0, alpha: 1.0)
        ])
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 8.0 / 255.0, green: 102.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0), range: NSRange(location: 45, length: 14))
        return attributedString
    }
    private func successAttributedString() -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: "Thank you for submitting your Guild Rep request.  All requests are handled in the order they are received. Reminder: if your interview is in less than 24 hours, call SPOG directly (206) 767-1150.", attributes: [
          .font: UIFont(name: "Roboto-Regular", size: 14.0)!,
          .foregroundColor: UIColor(white: 112.0 / 255.0, alpha: 1.0)
        ])
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 8.0 / 255.0, green: 102.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0), range: NSRange(location: 181, length: 14))
        return attributedString
    }
    
    private func submitForm() {
        let status = viewModel.validSubmitForm(name: name, serial: serial, phone: phone, email: email, dateOfInterview: dateOfInterview, timeOfInterview: timeOfInterview, investigator: investigator, nameOfWitness: nameOfWitness)
        
        if status {
            viewModel.requestGuildRep(name: name, serial: serial, phone: phone, email: email, dateOfInterview: appSharedData.getDateFormatter(format: "yyyy-MM-dd").string(from: selectedDate), timeOfInterview: appSharedData.getDateFormatter(format: "HH:MM:SS").string(from: selectedTime), investigator: investigator, nameOfWitness: nameOfWitness)
        }
    }
}

// MARK: - Form Text Field
struct FormTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            TextField("", text: $text, prompt: Text(title)
                .foregroundColor(Color(white: 200.0 / 255.0)))
                .font(.custom("HelveticaNeue-Regular", size: 14))
                .foregroundColor(.black)
                .textFieldStyle(PlainTextFieldStyle())
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled()
                .keyboardType(keyboardType)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color(white: 112.0 / 255.0), lineWidth: 1)
                )
        }
    }
}

// MARK: - Date Picker Field
struct DatePickerField: View {
    let title: String
    @Binding var date: Date
    @Binding var text: String
    @Binding var showPicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                showPicker = true
            }) {
                HStack {
                    Text(text.isEmpty ? title : text)
                        .font(.custom("HelveticaNeue-Regular", size: 14))
                        .foregroundColor(text.isEmpty ? Color(white: 200.0 / 255.0) : .black)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color(white: 112.0 / 255.0), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Picker Type Enum
enum PickerType {
    case date
    case time
}

// MARK: - Unified Picker Sheet
struct PickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var text: String
    @Binding var showPicker: Bool
    let pickerType: PickerType
    @Environment(\.dismiss) private var dismiss
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        switch pickerType {
        case .date:
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        case .time:
            formatter.dateStyle = .none
            formatter.timeStyle = .short
        }
        return formatter
    }
    
    private var navigationTitle: String {
        switch pickerType {
        case .date:
            return "Select Date"
        case .time:
            return "Select Time"
        }
    }
    
    private var displayedComponents: DatePickerComponents {
        switch pickerType {
        case .date:
            return .date
        case .time:
            return .hourAndMinute
        }
    }
    
    @ViewBuilder
    private var datePickerView: some View {
        switch pickerType {
        case .date:
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: displayedComponents
            )
            .datePickerStyle(.graphical)
        case .time:
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: displayedComponents
            )
            .datePickerStyle(.wheel)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                datePickerView
                    .padding()
                
                Spacer()
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showPicker = false
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        text = dateFormatter.string(from: selectedDate)
                        showPicker = false
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Time Picker Field
struct TimePickerField: View {
    let title: String
    @Binding var time: Date
    @Binding var text: String
    @Binding var showPicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                showPicker = true
            }) {
                HStack {
                    Text(text.isEmpty ? title : text)
                        .font(.custom("HelveticaNeue-Regular", size: 14))
                        .foregroundColor(text.isEmpty ? Color(white: 200.0 / 255.0) : .black)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color(white: 112.0 / 255.0), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}


// MARK: - Attributed Text View
struct AttributedTextView: UIViewRepresentable {
    let attributedString: NSMutableAttributedString
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedString
    }
}

#Preview {
    RequestGuidRep()
}

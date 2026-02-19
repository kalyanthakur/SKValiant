//
//  AccountView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 11/02/26.
//

import SwiftUI
import UIKit

struct AccountView: View {
    
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
    
    @State private var fname: String = ""
    @State private var lname: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    
    @State private var showImagePickerOptions = false
    @State private var showImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?



    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        Text("Update Account")
                            .font(.custom("HelveticaNeue-Bold", size: 18.0))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if let userData = appUserDefaults.userData {
                            Group {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                } else if let imagePath = userData.profileImage, !imagePath.isEmpty {
                                    let imageURL = appSharedData.constructImageURL(from: imagePath)
                                    AsyncImage(url: URL(string: imageURL)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 120, height: 120)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .cornerRadius(60)
                                                .frame(width: 120, height: 120)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.gray, lineWidth: 1)
                                                )
                                        case .failure:
                                            // Fallback to SPOG logo if image fails to load
                                            Image("SPOG_logo")
                                                .resizable()
                                                .scaledToFit()
                                                .cornerRadius(60)
                                                .frame(width: 120, height: 120)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.gray, lineWidth: 1)
                                                )
                                        @unknown default:
                                            Image("SPOG_logo")
                                                .resizable()
                                                .scaledToFit()
                                                .cornerRadius(60)
                                                .frame(width: 120, height: 120)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.gray, lineWidth: 1)
                                                )
                                        }
                                    }
                                } else {
                                    Image("SPOG_logo")
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(60)
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.gray, lineWidth: 1)
                                        )
                                }
                            }
                            .frame(width: 120, height: 120)
                            .onTapGesture {
                                showImagePickerOptions = true
                            }
                            VStack(spacing: 24) {
                                
                                // Name
                                FormTextField(title: "First Name", text: $fname)
                                
                                // Serial
                                FormTextField(title: "Last Name", text: $lname)
                                                                
                                // Non-Seattle Gov email address
                                FormTextField(title: "Email Address", text: $email, keyboardType: .emailAddress)
                                
                                // Phone
                                FormTextField(title: "Phone Number", text: $phone, keyboardType: .phonePad)
                                
                                
                                // Submit button
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        // Handle submit action
                                        updateForm()
                                    }) {
                                        Text("Update")
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
            }.onAppear(perform: {
                if let userData = appUserDefaults.userData {
                    if let name = userData.name {
                        let names = name.split(separator: " ")
                        if names.count > 1 {
                            fname = String(names[0])
                            lname = String(names[1])
                        } else if !names.isEmpty {
                            fname = String(names[0])
                        }
                    }
                    email = userData.email ?? ""
                    phone = userData.contactNo ?? ""
                }
            })
            .task {
                await Task { @MainActor in

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
            .confirmationDialog("Select Image", isPresented: $showImagePickerOptions, titleVisibility: .visible) {
                Button("Camera") {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        imagePickerSourceType = .camera
                        showImagePicker = true
                    }
                }
                Button("Photo Library") {
                    imagePickerSourceType = .photoLibrary
                    showImagePicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: imagePickerSourceType, selectedImage: $selectedImage)
            }
        }
    }
    
    private func updateForm() {
        let status = viewModel.validSubmitForm(fname: fname, lname: lname, phone: phone, email: email)
        
        if status {
            // Convert selectedImage UIImage to UIImage if available
            var profileImage: UIImage? = nil
            if let selectedImage = selectedImage {
                profileImage = selectedImage
            }
            
            viewModel.updateProfile(
                firstName: fname,
                lastName: lname,
                phone: phone,
                email: email,
                profileImage: profileImage
            )
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

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    AccountView()
}

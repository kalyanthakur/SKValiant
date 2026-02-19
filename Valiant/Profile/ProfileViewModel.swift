//
//  ProfileViewModel.swift
//  Valiant
//
//  Created by Kalyan Thakur on 11/02/26.
//

import Foundation
import UIKit

class ProfileViewModel: ObservableObject {
    
    @Published var notifications = [NotificationItem]()
    @Published var showSuccess = false
    @Published var arrSpogEvents = [SpogEvent]()
    @Published var arrDocuments = [DocumentItem]()
    @Published var arrPresidentsMessage = [PresidentsMessage]()


    init() {
        
    }
    
    
    func validSubmitForm(fname: String, lname: String, phone: String, email: String) -> Bool {
        
        if fname.isEmpty {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter first name")
            return false
        } else if lname.isEmpty {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter last name")
            return false
        } else if phone.isEmpty {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter phone number")
            return false
        } else if appSharedData.isValidEmail(email) == false && email.isEmpty {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter valid email")
            return false
        }
        
        return true
    }
    
    func updateProfile(firstName: String, lastName: String, phone: String, email: String, profileImage: UIImage?) {
        var parameters: [String: String] = [:]
        
        // Add text parameters only if they have values
        if !firstName.isEmpty {
            parameters["firstName"] = firstName
        }
        if !lastName.isEmpty {
            parameters["lastName"] = lastName
        }
        if !email.isEmpty {
            parameters["email"] = email
        }
        if !phone.isEmpty {
            parameters["contactNo"] = phone
        }
        
        // Convert UIImage to Data if provided
        var imageData: Data? = nil
        if let profileImage = profileImage {
            imageData = profileImage.jpegData(compressionQuality: 0.8)
        }
        
        LoadingIndicatorView.show()
        networkManager.uploadMultipartWithFile(
            urlString: WEBURL.updateProfile,
            parameters: parameters,
            imageData: imageData,
            imageKey: "profileImage"
        ) {  response, error in
            LoadingIndicatorView.hide()
            if error == nil, let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                    let apiResponse = try JSONDecoder().decode(OTPVerifyResponse.self, from: jsonData)
                    if apiResponse.status == 200 {
                        appUserDefaults.userData = apiResponse.data
                        appSharedData.showAlertControllerWith(title: projectName, andMessage: apiResponse.message ?? "Profile updated successfully")
                    } else {
                        appSharedData.showAlertControllerWith(title: projectName, andMessage: apiResponse.message ?? "Failed to update profile")
                    }
                } catch {
                    Logger.logDecodingError(error, context: "ProfileViewModel")
                    let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "update profile")
                    appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                }
            } else {
                let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "update profile")
                appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
            }
        }
    }
    
    func getAllNotifications()  {
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.getAllNotifications, postParameters: nil) { [weak self] response, error in
            LoadingIndicatorView.hide()
            guard let self = self else { return }
                        
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(NotificationsResponse.self, from: jsonData)
                    if response.status == 200 {
                        DispatchQueue.main.async {
                            self.notifications = response.data ?? []
                        }
                    } else {
                        DispatchQueue.main.async {
                            appSharedData.showAlertControllerWith(title: projectName, andMessage: response.message ?? "")
                        }
                    }
                } catch {
                    Logger.logDecodingError(error, context: "DashboardViewModel")
                    let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "load announcements")
                    DispatchQueue.main.async {
                        appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                    }
                }
            } else {
                let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "load schedule")
                DispatchQueue.main.async {
                    appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                }
            }
        }
    }
    
    func markNotificationAsRead(notificationId: Int) {
        networkManager.executeServiceWithURL(urlString: WEBURL.markNotificationRead, postParameters: ["notificationId": notificationId]) { [weak self] response, error in
            guard let self = self else { return }
            
            if error == nil, let result = response {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let apiResponse = try JSONDecoder().decode(OTPVerifyResponse.self, from: jsonData)
                    if apiResponse.status == 200 {
                        // Update local notification to mark as read
                        DispatchQueue.main.async {
                            if let index = self.notifications.firstIndex(where: { $0.id == notificationId }) {
                                // Create a new notification with isRead = true
                                var updatedNotification = self.notifications[index]
                                // Since NotificationItem is a struct with let properties, we need to update the array
                                updatedNotification.isRead = true
                                // For now, just refresh the list
                                self.notifications[index] = updatedNotification
                            }
                        }
                    }
                } catch {
                    Logger.logDecodingError(error, context: "ProfileViewModel")
                }
            }
        }
    }
    
    func validSubmitForm(name: String, message:String) -> Bool {
        
        if name.isEmpty {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter subject")
            return false
        }  else if message.isEmpty {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter message")
            return false
        }
        
        return true
    }

    func appSupport(name: String, message:String)  {
        
        let param = [
            "subject": name,
            "message": message]
        
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.appSupport, postParameters: param) { response, error in
            LoadingIndicatorView.hide()
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(OTPVerifyResponse.self, from: jsonData)
                    if response.status == 200 {
                        self.showSuccess = true
                    } else {
                        appSharedData.showAlertControllerWith(title: projectName, andMessage: response.message ?? "")
                    }
                } catch {
                    Logger.logDecodingError(error, context: "SplashViewModel")
                    let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "verify OTP")
                    appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                }
            } else {
                let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "load schedule")
                appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
            }
        }
    }
    
    func deleteAccount()  {
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.deleteAccount, postParameters: nil) { [weak self] response, error in
            LoadingIndicatorView.hide()
            guard let _ = self else { return }
                        
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(BookmarkResponse.self, from: jsonData)
                    if response.status == 200 {
                        // Navigate to login screen from anywhere
                        DispatchQueue.main.async {
                            NavigationCoordinator.shared.navigateToLoginUIKit()
                        }
                    } else {
                        DispatchQueue.main.async {
                            appSharedData.showAlertControllerWith(title: projectName, andMessage: response.message ?? "")
                        }
                    }
                } catch {
                    Logger.logDecodingError(error, context: "DashboardViewModel")
                    let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "load announcements")
                    DispatchQueue.main.async {
                        appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                    }
                }
            } else {
                let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "load schedule")
                DispatchQueue.main.async {
                    appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                }
            }
        }
    }
    
    func getBookmarkList()  {
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.getBookmarkList, postParameters: nil) { [weak self] response, error in
            LoadingIndicatorView.hide()
            guard let self = self else { return }
                        
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(BookmarksListResponse.self, from: jsonData)
                    if response.status == 200 {
                        self.arrDocuments = response.data?.spogDocuments ?? []
                        self.arrSpogEvents = response.data?.events ?? []
                        self.arrPresidentsMessage = response.data?.presidentMessages ?? []

                    } else {
                        DispatchQueue.main.async {
                            appSharedData.showAlertControllerWith(title: projectName, andMessage: response.message ?? "")
                        }
                    }
                } catch {
                    Logger.logDecodingError(error, context: "DashboardViewModel")
                    let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "load announcements")
                    DispatchQueue.main.async {
                        appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                    }
                }
            } else {
                let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "load schedule")
                DispatchQueue.main.async {
                    appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                }
            }
        }
    }
}

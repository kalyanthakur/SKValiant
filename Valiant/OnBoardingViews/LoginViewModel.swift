//
//  LoginViewModel.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//

import Foundation
import UIKit

class LoginViewModel: ObservableObject {
    
    @Published var showSuccess = false
    @Published var showOTPSuccess = false
    
    init() {
        
    }
    
    func validateInput(_ text: String) -> Bool {
        // Trim whitespace
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if text is numeric
        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: trimmed)) {
            // Validate as phone number
            if trimmed.count == 10 {
                return true
            } else {
                appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter valid mobile or email id!")
                return false
            }
        } else {
            // Validate as email address
            if appSharedData.isValidEmail(text) {
                return true
            } else {
                appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter valid mobile or email id!")
                return false
            }
        }
    }

    
    func validateOTPInput(_ text: String) -> Bool {
        if text.count < 4 {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter valid OTP")
            return false
        }
        return true
    }
    
    func makeLoginRequest(text: String)  {
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.sendOTP, postParameters: ["contactNo":text]) { response, error in
            LoadingIndicatorView.hide()
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(LoginResponse.self, from: jsonData)
                    if response.status == 200 {
                        self.showSuccess = true
                    } else {
                        appSharedData.showAlertControllerWith(title: projectName, andMessage: response.message ?? "")
                    }
                } catch {
                    Logger.logDecodingError(error, context: "DashboardViewModel")
                    let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "load announcements")
                    appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                }
            } else {
                let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "load schedule")
                appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
            }
        }
    }
    func makeOTPVerifyRequest(contactNo: String, otp: String)  {
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.verifyOTP, postParameters: ["contactNo":contactNo,"otp":otp]) { [weak self] response, error in
            guard let self = self else {
                LoadingIndicatorView.hide()
                return
            }
            
            // Always hide loading indicator first
            DispatchQueue.main.async {
                LoadingIndicatorView.hide()
            }
            
            if error == nil,let result = response {
                do {
                    // Convert dictionary → Data
                    let jsonData = try JSONSerialization.data(withJSONObject: result.dictionaryObject ?? [:], options: [])
                    let response = try JSONDecoder().decode(OTPVerifyResponse.self, from: jsonData)
                    if response.status == 200 {
                        appUserDefaults.userData = response.data
                        // Add small delay to ensure loading indicator is hidden before navigation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.showOTPSuccess = true
                            self.makeUpdateDeviceTokenRequest()
                        }
                    } else {
                        DispatchQueue.main.async {
                            appSharedData.showAlertControllerWith(title: projectName, andMessage: response.message ?? "")
                        }
                    }
                } catch {
                    Logger.logDecodingError(error, context: "SplashViewModel")
                    let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "verify OTP")
                    DispatchQueue.main.async {
                        appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                    }
                }
            } else {
                let errorMessage = appSharedData.getUserFriendlyErrorMessage(from: error, context: "verify OTP")
                DispatchQueue.main.async {
                    appSharedData.showAlertControllerWith(title: projectName, andMessage: errorMessage)
                }
            }
        }
    }
    
    func makeUpdateDeviceTokenRequest()  {
        if let deviceToken = appUserDefaults.deviceToken {
            networkManager.executeServiceWithURL(urlString: WEBURL.updateDeviceToken, postParameters: ["deviceToken":deviceToken]) { response, error in
            }
        }
    }
}

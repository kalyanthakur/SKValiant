//
//  ContactViewModel.swift
//  Valiant
//
//  Created by Kalyan Thakur on 09/02/26.
//

import Foundation

class ContactViewModel: ObservableObject {
    
    @Published var showSuccess = false
    
    init() {
        
    }
    
    
    func validSubmitForm(name: String, serial: String, phone: String, email: String, message:String) -> Bool {
        
        if name.isEmpty {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter full name")
            return false
        } else if serial.isEmpty {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter Serial")
            return false
        } else if phone.isEmpty {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter phone number")
            return false
        } else if appSharedData.isValidEmail(email) == false && email.isEmpty {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter valid email")
            return false
        } else if message.isEmpty {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter message")
            return false
        }
        
        return true
    }

    func contactSpog(name: String, serial: String, phone: String, email: String, message:String)  {
        
        let param = [
            "fullName": name,
            "serial": serial,
            "phone": phone,
            "email": email,
            "message": message]
        
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.contactSpog, postParameters: param) { response, error in
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
}

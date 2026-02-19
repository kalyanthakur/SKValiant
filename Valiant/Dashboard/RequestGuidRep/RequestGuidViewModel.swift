//
//  RequestGuidViewModel.swift
//  Valiant
//
//  Created by Kalyan Thakur on 09/02/26.
//

import Foundation
import UIKit

class RequestGuidViewModel: ObservableObject {
    
    @Published var showSuccess = false
    
    init() {
        
    }
    
    
    func validSubmitForm(name: String, serial: String, phone: String, email: String, dateOfInterview:String, timeOfInterview: String, investigator: String, nameOfWitness: String) -> Bool {
        
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
        } else if dateOfInterview.isEmpty {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter date of Interview")
            return false
        } else if timeOfInterview.isEmpty {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter time of Interview")
            return false
        } else if investigator.isEmpty {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter investigator")
            return false
        } else if nameOfWitness.isEmpty {
            appSharedData.showAlertControllerWith(title: projectName, andMessage: "Please enter name of Witness")
            return false
        }
        
        return true
    }

    func requestGuildRep(name: String, serial: String, phone: String, email: String, dateOfInterview:String, timeOfInterview: String, investigator: String, nameOfWitness: String)  {
        
        let param = [
            "fullName": name,
            "serial": serial,
            "phone": phone,
            "email": email,
            "dateOfInterview": dateOfInterview,
            "timeOfInterview": timeOfInterview,
            "investigator": investigator,
            "nameOfWitness": nameOfWitness
          ]
        LoadingIndicatorView.show()
        networkManager.executeServiceWithURL(urlString: WEBURL.requestGuildRep, postParameters: param) { response, error in
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

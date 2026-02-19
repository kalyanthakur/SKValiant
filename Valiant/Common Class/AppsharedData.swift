//
//  AppsharedData.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//


import UIKit
import CoreLocation
import CoreTelephony
import SwiftUICore

class AppsharedData: NSObject {
    
    static let sharedInstance = AppsharedData()
    
    func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        
        guard let rootVC = rootViewController ?? UIApplication.shared.currentKeyWindow?.rootViewController else {
            return nil
        }
        
        // Safely handle UINavigationController
        if let navigationController = rootVC as? UINavigationController {
            // Safely get the last view controller, fallback to navigationController itself if empty
            if let lastViewController = navigationController.viewControllers.last {
                return getVisibleViewController(lastViewController)
            } else {
                // If navigation stack is empty, return the navigation controller itself
                return navigationController
            }
        }
        
        // Safely handle UITabBarController
        if let tabBarController = rootVC as? UITabBarController {
            // Safely get selected view controller, fallback to tabBarController itself if nil
            if let selectedViewController = tabBarController.selectedViewController {
                return getVisibleViewController(selectedViewController)
            } else {
                // If no selected view controller, return the tab bar controller itself
                return tabBarController
            }
        }
        
        // Handle presented view controllers
        if let presentedVC = rootVC.presentedViewController {
            return getVisibleViewController(presentedVC)
        }
        
        return rootVC
    }

    func dayWithSuffix(from date: String, fromFormat: String) -> String {
        // Use cached formatter for better performance
        let dateFormatter = DateFormatterManager.shared.formatter(for: fromFormat)
        let dateToCheck = dateFormatter.date(from: date) ?? Date()
        
        let day = Calendar.current.component(.day, from: dateToCheck)
        
        let suffix: String
        switch day {
        case 11...13:
            suffix = "th"
        default:
            switch day % 10 {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        
        return "\(day)\(suffix)"
    }
    
    func constructImageURL(from imagePath: String) -> String {
        let baseURL = WEBURL.imageURL
        // Remove leading slash if present to avoid double slashes
        let cleanPath = imagePath.hasPrefix("/") ? String(imagePath.dropFirst()) : imagePath
        return baseURL + cleanPath
    }
    func getDateFormatter(format: String) -> DateFormatter {
        // Use cached formatter for better performance
        return DateFormatterManager.shared.formatter(for: format)
    }
    func convertDateFormatFromForDate(fromFormat: String, toFormat: String, stringDate: String)-> String {
        // Use cached formatters for better performance
        let inputFormatter = DateFormatterManager.shared.formatter(for: fromFormat)
        let outputFormatter = DateFormatterManager.shared.formatter(for: toFormat)
        
        let date = inputFormatter.date(from: stringDate)
        return outputFormatter.string(from: date ?? Date())
    }
    
    func getDayName(fromFormat: String,stringDate: String) -> String {
        let calendar = Calendar.current
        // Use cached formatter for better performance
        let dateFormatter = DateFormatterManager.shared.formatter(for: fromFormat)
        let dateToCheck = dateFormatter.date(from: stringDate) ?? Date()

        if calendar.isDateInToday(dateToCheck) {
            Logger.debug("The date is today")
            return "Today"
        } else if calendar.isDateInTomorrow(dateToCheck) {
            Logger.debug("The date is tomorrow")
            return "Tomorrow"
        } else {
            Logger.debug("The date is neither today nor tomorrow")
            return convertDateFormatFromForDate(fromFormat: fromFormat, toFormat: "EEEE", stringDate: stringDate)
        }

    }
    
    //MARK: - For validating the URL
    func validateUrl (urlString: NSString) -> Bool {
        let urlRegEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: urlString)
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", options: .caseInsensitive)
            return regex.firstMatch(in: testStr, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, testStr.count)) != nil
        } catch {
            return false
        }
    }
    
    func isPasswordValid(_ testStr:String) -> Bool {
        // let stricterFilter = false
        let emailReg = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}"
        //let emailRegEx = stricterFilter ? stricterFilterString : laxString;
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailReg)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    func showAlertControllerWith(title : String, andMessage:String)  {
        let viewcontroller = self.getVisibleViewController(nil)
        let otherAlert = UIAlertController(title: title, message: andMessage, preferredStyle: UIAlertController.Style.alert)
        
        
        let dismiss = UIAlertAction(title: "OK", style:UIAlertAction.Style.cancel, handler: nil)
        
        // relate actions to controllers
        otherAlert.addAction(dismiss)
        
        viewcontroller?.present(otherAlert, animated: true, completion: nil)
    }
    
    func showAlertwithOptions (optionTitle:String,cancelTitle:String,title:String,message:String,completion:@escaping (Bool) -> Void) {
        
        guard  let viewcontroller = self.getVisibleViewController(nil) else {
            return
        }
        
        let alert: UIAlertController = UIAlertController(title: title,
                                                         message: message,
                                                         preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: optionTitle, style: .default) { (alert) in
            completion(true)
        }
        
        let noAction = UIAlertAction(title: cancelTitle, style: .default) { (alert) in
            completion(false)
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        viewcontroller.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Error Message Utilities
    
    /// Converts an error to a user-friendly, actionable error message
    /// - Parameters:
    ///   - error: The error to convert
    ///   - context: Optional context about what operation failed (e.g., "loading attendance", "saving profile")
    /// - Returns: A user-friendly error message
    func getUserFriendlyErrorMessage(from error: Error?, context: String = "") -> String {
        guard let error = error else {
            return context.isEmpty ? "Something went wrong. Please try again." : "Unable to \(context). Please try again."
        }
        
        let nsError = error as NSError
        let errorCode = nsError.code
        let errorDomain = nsError.domain
        
        // Network-related errors
        if errorDomain == NSURLErrorDomain {
            switch errorCode {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                return "No internet connection. Please check your network settings and try again."
            case NSURLErrorTimedOut:
                return "The request took too long. Please check your connection and try again."
            case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                return "Unable to reach the server. Please check your internet connection and try again."
            case NSURLErrorBadServerResponse:
                return "The server returned an error. Please try again later."
            case NSURLErrorCancelled:
                return "The request was cancelled."
            default:
                return "Network error occurred. Please check your connection and try again."
            }
        }
        
        // Decoding errors
        if error is DecodingError {
            let decodingContext = context.isEmpty ? "data" : context
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, _):
                    return "Unable to process \(decodingContext). Missing required information: \(key.stringValue)."
                case .typeMismatch(_):
                    return "Unable to process \(decodingContext). Data format is incorrect."
                case .valueNotFound(_):
                    return "Unable to process \(decodingContext). Required value is missing."
                case .dataCorrupted(_):
                    return "Unable to process \(decodingContext). The data appears to be corrupted."
                @unknown default:
                    return "Unable to process \(decodingContext). Please try again."
                }
            }
        }
        
        // Encoding errors
        if error is EncodingError {
            let encodingContext = context.isEmpty ? "data" : context
            return "Unable to save \(encodingContext). Please try again."
        }
        
        // Check for specific error messages in userInfo
        if let userInfo = nsError.userInfo[NSLocalizedDescriptionKey] as? String,
           !userInfo.isEmpty {
            // If it's already user-friendly, use it
            if !userInfo.contains("Error Domain") && !userInfo.contains("Code=") {
                return userInfo
            }
        }
        
        // Generic fallback based on context
        if !context.isEmpty {
            return "Unable to \(context). Please try again."
        }
        
        return "Something went wrong. Please try again."
    }
}

extension UIApplication {
    var currentKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}


extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
    
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            hideKeyboard()
        }
    }
}


extension Int {
    var ordinalString: String {
        let suffix: String
        let ones = self % 10
        let tens = (self / 10) % 10

        if tens == 1 {
            suffix = "th"
        } else {
            switch ones {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }

        return "\(self)\(suffix)"
    }
}

extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexString = hexString.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)

        let r, g, b, a: Double
        switch hexString.count {
        case 6: // RGB (no alpha)
            r = Double((rgb >> 16) & 0xFF) / 255.0
            g = Double((rgb >> 8) & 0xFF) / 255.0
            b = Double(rgb & 0xFF) / 255.0
            a = 1.0
        case 8: // RGBA
            r = Double((rgb >> 24) & 0xFF) / 255.0
            g = Double((rgb >> 16) & 0xFF) / 255.0
            b = Double((rgb >> 8) & 0xFF) / 255.0
            a = Double(rgb & 0xFF) / 255.0
        default:
            r = 1.0; g = 1.0; b = 1.0; a = 1.0
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

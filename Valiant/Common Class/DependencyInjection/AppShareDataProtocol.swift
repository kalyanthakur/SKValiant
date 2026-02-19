//
//  AppShareDataProtocol.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//


import Foundation
import UIKit

/// Protocol for shared app utilities - enables dependency injection and testing
protocol AppShareDataProtocol {
    func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController?
    func dayWithSuffix(from date: String, fromFormat: String) -> String
    func getDateFormatter(format: String) -> DateFormatter
    func convertDateFormatFromForDate(fromFormat: String, toFormat: String, stringDate: String) -> String
    func getDayName(fromFormat: String, stringDate: String) -> String
    func validateUrl(urlString: NSString) -> Bool
    func isValidEmail(_ testStr: String) -> Bool
    func isPasswordValid(_ testStr: String) -> Bool
    func showAlertControllerWith(title: String, andMessage: String)
    func showAlertwithOptions(
        optionTitle: String,
        cancelTitle: String,
        title: String,
        message: String,
        completion: @escaping (Bool) -> Void
    )
    func getUserFriendlyErrorMessage(from error: Error?, context: String) -> String
}

/// Extension to make AppsharedData conform to AppShareDataProtocol
extension AppsharedData: AppShareDataProtocol {
    // AppsharedData already implements all required methods
    // This extension makes it conform to the protocol
}
//
//  MockNetworkManager.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//


import Foundation
import UIKit

/// Mock implementations for testing
/// These can be used in unit tests to verify ViewModel behavior

// MARK: - Mock NetworkManager
class MockNetworkManager: NetworkManagerProtocol {
    var executeServiceWithURLCalled = false
    var executeServiceWithURLParameters: (urlString: String, postParameters: [String: Any]?)?
    var executeServiceWithURLResponse: JSON?
    var executeServiceWithURLError: NSError?
    
    func executeServiceWithURL(
        urlString: String,
        postParameters: [String: Any]?,
        callback: @escaping (_ response: JSON?, _ error: NSError?) -> Void
    ) {
        executeServiceWithURLCalled = true
        executeServiceWithURLParameters = (urlString, postParameters)
        
        // Simulate async response
        DispatchQueue.main.async {
            callback(self.executeServiceWithURLResponse, self.executeServiceWithURLError)
        }
    }
    
    func sendMultipartPostData(
        _ urlString: String,
        withParam paramDict: [String: Any],
        callback: @escaping (_ status: Bool, _ taskError: Error?) -> Void
    ) {
        // Mock implementation
        callback(true, nil)
    }
    
    func postRequestWithMultipPart(
        _ urlString: String,
        withParam paramDict: [String: Any],
        callback: @escaping (_ json: NSDictionary?, _ taskError: Error?) -> Void
    ) {
        // Mock implementation
        callback(nil, nil)
    }
    
    func invalidateCache(for urlString: String) {
        // Mock implementation
    }
    
    func clearAllCache() {
        // Mock implementation
    }
}

// MARK: - Mock AppUserDefaults
class MockAppUserDefaults: AppUserDefaultsProtocol {
//    var userData: VerifyUserData?
//    var studentData: StudentDetail?
    var deviceToken: String?
    
    var invalidateCacheCalled = false
    
    func invalidateCache() {
        invalidateCacheCalled = true
    }
}

// MARK: - Mock AppShareData
class MockAppShareData: AppShareDataProtocol {
    var showAlertControllerWithCalled = false
    var showAlertControllerWithParameters: (title: String, message: String)?
    var showAlertwithOptionsCalled = false
    var getUserFriendlyErrorMessageCalled = false
    
    func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        return nil
    }
    
    func dayWithSuffix(from date: String, fromFormat: String) -> String {
        return "1st"
    }
    
    func getDateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }
    
    func convertDateFormatFromForDate(fromFormat: String, toFormat: String, stringDate: String) -> String {
        return stringDate
    }
    
    func getDayName(fromFormat: String, stringDate: String) -> String {
        return "Today"
    }
    
    func validateUrl(urlString: NSString) -> Bool {
        return true
    }
    
    func isValidEmail(_ testStr: String) -> Bool {
        return testStr.contains("@")
    }
    
    func isPasswordValid(_ testStr: String) -> Bool {
        return testStr.count >= 8
    }
    
    func showAlertControllerWith(title: String, andMessage: String) {
        showAlertControllerWithCalled = true
        showAlertControllerWithParameters = (title, andMessage)
    }
    
    func showAlertwithOptions(
        optionTitle: String,
        cancelTitle: String,
        title: String,
        message: String,
        completion: @escaping (Bool) -> Void
    ) {
        showAlertwithOptionsCalled = true
        completion(false)
    }
    
    func getUserFriendlyErrorMessage(from error: Error?, context: String) -> String {
        getUserFriendlyErrorMessageCalled = true
        return error?.localizedDescription ?? "Unknown error"
    }
}

/// Mock dependency container for testing
extension DependencyContainer {
    static func mock(
        networkManager: NetworkManagerProtocol? = nil,
        appUserDefaults: AppUserDefaultsProtocol? = nil,
        appShareData: AppShareDataProtocol? = nil
    ) -> DependencyContainer {
        return DependencyContainer(
            networkManager: networkManager ?? MockNetworkManager(),
            appUserDefaults: appUserDefaults ?? MockAppUserDefaults(),
            appShareData: appShareData ?? MockAppShareData()
        )
    }
}

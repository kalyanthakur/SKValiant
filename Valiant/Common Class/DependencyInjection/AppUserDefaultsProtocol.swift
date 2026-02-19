//
//  AppUserDefaultsProtocol.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//


import Foundation

/// Protocol for user defaults and storage operations - enables dependency injection and testing
protocol AppUserDefaultsProtocol {
//    var userData: VerifyUserData? { get set }
//    var studentData: StudentDetail? { get set }
//    var deviceToken: String? { get set }
    
    func invalidateCache()
}

/// Extension to make AppUserDefaults conform to AppUserDefaultsProtocol
extension AppUserDefaults: AppUserDefaultsProtocol {
    // AppUserDefaults already implements all required properties
    // This extension makes it conform to the protocol
}

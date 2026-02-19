//
//  Constant.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//

import UIKit

let appSharedData = AppsharedData.sharedInstance
let networkManager = NetworkManager.sharedInstance
let appUserDefaults = AppUserDefaults.shared

struct WEBURL {
    static let baseURL = "https://valiant.sourcekode.in/api/"
    static let imageURL = "https://valiant.sourcekode.in/"
    static let sendOTP = baseURL + "auth/sendOTP"
    static let verifyOTP = baseURL + "auth/verifyOTP"
    static let updateDeviceToken = baseURL + "auth/updateDeviceToken"
    static let updateProfile = baseURL + "auth/myProfile/update"
    static let getSpogHomeData = baseURL + "spogHomeData"
    static let spogAlerts = baseURL + "spogAlerts"
    static let spogAlertDetailsById = baseURL + "spogAlertDetailsById"
    static let getSpogEvents = baseURL + "spogEvents"
    static let spogEventDetailsById = baseURL + "spogEventDetailsById"
    static let getSpogPresidentsMessages = baseURL + "spogPresidentsMessages"
    static let spogPresidentsMessageDetailsById = baseURL + "spogPresidentsMessageDetailsById"
    static let getSpogDocuments = baseURL + "spogDocuments"
    static let spogDocumentDetailsById = baseURL + "spogDocumentDetailsById"
    static let requestGuildRep = baseURL + "requestGuildRep"
    static let contactSpog = baseURL + "contactSpog"
    static let saucierScholarshipPosts = baseURL + "saucierScholarshipPosts"
    static let votePost = baseURL + "votePost"
    static let getAllNotifications = baseURL + "notifications"
    static let markNotificationRead = baseURL + "notification/markAsRead"
    static let bookmarkPost = baseURL + "bookmark"
    static let appSupport = baseURL + "support"
    static let deleteAccount = baseURL + "deleteAccount"
    static let getBookmarkList = baseURL + "getBookmarkList"
}

let projectName = "Valiant"
struct NotificationNames {
    static let popToLogin = "com.iOS.Valiant.popToLogin"
    static let loginSuccess = "com.iOS.Valiant.loginSuccess"
}

let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let buildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String

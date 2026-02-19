//
//  AppUserDefaults.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//


import UIKit

class AppUserDefaults {
    private let defaults = UserDefaults.standard
    private let keychainManager = KeychainManager.shared
    
    // Serial queue for thread-safe operations
    private let serialQueue = DispatchQueue(label: "com.iOS.Valiant.appuserdefaults", qos: .utility)
    
    // In-memory cache to avoid repeated JSON decoding
    // Access to these should be synchronized, but since property access is typically
    // from main thread and we update cache synchronously in setters, this is acceptable
    private var userDataCacheValid = false
    
    private let UDisLogin = "isLogin"
    private let kUserData = "kUserData"
    private let kDeviceToken = "kDeviceToken"


    class var shared: AppUserDefaults {
        struct Static {
            static let instance = AppUserDefaults()
        }
      
        return Static.instance
    }
    
    // MARK: - User Data Storage
    var userData: UserData? {
        get {
            // Decode from UserDefaults
            guard let data = defaults.data(forKey: kUserData) else {
                return nil
            }
            
            return try? JSONDecoder().decode(UserData.self, from: data)
        }
        set {
            serialQueue.sync {
                if let userData = newValue {
                    if let encoded = try? JSONEncoder().encode(userData) {
                        defaults.set(encoded, forKey: kUserData)
                        defaults.set(true, forKey: UDisLogin)
                    }
                } else {
                    defaults.removeObject(forKey: kUserData)
                    defaults.set(false, forKey: UDisLogin)
                }
                userDataCacheValid = false
            }
        }
    }
    var deviceToken: String? {
        get {
            defaults.string(forKey: kDeviceToken)
        }
        set {
            if newValue != nil {
                defaults.set(newValue, forKey: kDeviceToken)
            } else {
                defaults.removeObject(forKey: kDeviceToken)
            }
        }
    }
    /// Invalidates the in-memory cache, forcing a fresh decode on next access
    /// This is useful when you know the underlying data has changed externally
    func invalidateCache() {
        userDataCacheValid = false
    }
}

//
//  KeychainManager.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//


import Foundation
import Security

/// Manages secure storage of sensitive data using iOS Keychain
class KeychainManager {
    static let shared = KeychainManager()
    
    private let service: String
    
    private init() {
        // Use bundle identifier as service name
        service = Bundle.main.bundleIdentifier ?? "com.iOS.Valiant"
    }
    
    // MARK: - Token Storage Keys
    private let kAuthToken = "auth_token"
    private let kTokenMigrationKey = "token_migrated_to_keychain"
    
    // MARK: - Public Methods
    
    /// Stores authentication token securely in Keychain
    func saveToken(_ token: String) -> Bool {
        guard let data = token.data(using: .utf8) else {
            Logger.error("Failed to convert token to data")
            return false
        }
        
        // Delete existing token first
        let _ = deleteToken()
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: kAuthToken,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            Logger.info("Token saved to Keychain successfully")
            return true
        } else {
            Logger.error("Failed to save token to Keychain: \(status)")
            return false
        }
    }
    
    /// Retrieves authentication token from Keychain
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: kAuthToken,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let token = String(data: data, encoding: .utf8) {
            return token
        } else if status == errSecItemNotFound {
            Logger.debug("No token found in Keychain")
            return nil
        } else {
            Logger.error("Failed to retrieve token from Keychain: \(status)")
            return nil
        }
    }
    
    /// Deletes authentication token from Keychain
    func deleteToken() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: kAuthToken
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            Logger.info("Token deleted from Keychain")
            return true
        } else {
            Logger.error("Failed to delete token from Keychain: \(status)")
            return false
        }
    }
    
    /// Checks if token exists in Keychain
    func hasToken() -> Bool {
        return getToken() != nil
    }
    
    // MARK: - Migration Support
    
    /// Marks that token migration from UserDefaults to Keychain has been completed
    func markTokenMigrated() {
        UserDefaults.standard.set(true, forKey: kTokenMigrationKey)
    }
    
    /// Checks if token migration has been completed
    func isTokenMigrated() -> Bool {
        return UserDefaults.standard.bool(forKey: kTokenMigrationKey)
    }
    
    
    
    // MARK: - Generic Keychain Methods (for future use)
    
    /// Generic method to save any string value to Keychain
    func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }
        
        let _ = delete(forKey: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Generic method to retrieve string value from Keychain
    func get(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }
        
        return nil
    }
    
    /// Generic method to delete value from Keychain
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

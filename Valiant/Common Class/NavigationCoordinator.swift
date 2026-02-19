//
//  NavigationCoordinator.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//


import Foundation
import SwiftUI
import UIKit

/// Global navigation coordinator for handling app-wide navigation
/// Enables navigation to login screen from anywhere in the app
class NavigationCoordinator: ObservableObject {
    static let shared = NavigationCoordinator()
    
    @Published var shouldNavigateToLogin = false
    
    private init() {
        // Listen for token expiration notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTokenExpiration),
            name: Notification.Name(NotificationNames.popToLogin),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Navigate to login screen programmatically
    func navigateToLogin() {
        DispatchQueue.main.async { [weak self] in
            self?.shouldNavigateToLogin = true
        }
    }
    
    /// Handle token expiration notification
    @objc private func handleTokenExpiration() {
        navigateToLogin()
    }
    
    /// Navigate to login using UIKit (for non-SwiftUI contexts)
    /// This method ensures navigation to login screen from anywhere in the app
    /// Note: User data should be cleared before calling this method
    func navigateToLoginUIKit() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Post notification for SwiftUI views to handle
            // This ensures SwiftUI views can react to token expiration
            NotificationCenter.default.post(name: Notification.Name(NotificationNames.popToLogin), object: nil)
            
            // Also trigger the published property for SwiftUI observation
            self.shouldNavigateToLogin = true
            
            // Get the root view controller for UIKit navigation
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                return
            }
            
            // Find the topmost view controller
            var topViewController = rootViewController
            while let presented = topViewController.presentedViewController {
                topViewController = presented
            }
            
            // Dismiss any presented view controllers (modals, sheets, etc.)
            if topViewController.presentedViewController != nil {
                topViewController.dismiss(animated: false) {
                    // Retry navigation after dismissing
                    self.navigateToLoginUIKit()
                }
                return
            }
            
            // If we're in a navigation controller, pop to root
            if let navController = topViewController as? UINavigationController {
                navController.popToRootViewController(animated: true)
            } else if let navController = topViewController.navigationController {
                navController.popToRootViewController(animated: true)
            }
        }
    }
}
//
//  ContentView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 30/01/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplash: Bool = true
    @State private var isLoggedIn: Bool = false
    @ObservedObject private var navigationCoordinator = NavigationCoordinator.shared

    var body: some View {
        ZStack {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                if isLoggedIn {
                    DashBoardView()
                        .transition(.opacity)
                } else {
                    LoginView()
                        .transition(.opacity)
                }
                    }
                }
        .onAppear {
            // Check if user is already logged in
            isLoggedIn = appUserDefaults.userData != nil
            
            // Show splash for 3 seconds, then transition to appropriate view
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
        withAnimation {
                    showSplash = false
            }
        }
        }
        .onChange(of: navigationCoordinator.shouldNavigateToLogin) { shouldNavigate in
            if shouldNavigate {
                // Reset the flag
                navigationCoordinator.shouldNavigateToLogin = false
                // Navigate to login
                withAnimation {
                    isLoggedIn = false
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name(NotificationNames.popToLogin))) { _ in
            // Handle notification for token expiration
            withAnimation {
                isLoggedIn = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name(NotificationNames.loginSuccess))) { _ in
            // Handle login success - navigate to dashboard
            withAnimation {
                isLoggedIn = true
            }
        }
    }
}


#Preview {
    ContentView()
}

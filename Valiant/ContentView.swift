//
//  ContentView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 30/01/26.
//

import SwiftUI
import Firebase
import UserNotifications
import Mixpanel



class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        Messaging.messaging().delegate = self

        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        } else {
          let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        Mixpanel.initialize(token: "1513f2948a5ffe519fb263d697b2a0a0",
                            trackAutomaticEvents: false,
                            instanceName: "currentInstance")
        //enable debug log after initialization
        Mixpanel.mainInstance().loggingEnabled = true

        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

      if let messageID = userInfo[gcmMessageIDKey] {
        Logger.app("Push notification received - Message ID: \(messageID)")
      }

      Logger.app("Push notification userInfo: \(userInfo)")

      completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        appUserDefaults.deviceToken = fcmToken ?? ""
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    if let messageID = userInfo[gcmMessageIDKey] {
        Logger.app("Notification will present - Message ID: \(messageID)")
    }

    Logger.app("Notification userInfo: \(userInfo)")

    // Change this to your preferred presentation option
    completionHandler([[.banner, .badge, .sound]])
  }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

    }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

    if let messageID = userInfo[gcmMessageIDKey] {
      Logger.app("Notification tapped - Message ID: \(messageID)")
    }

    Logger.app("Notification tapped userInfo: \(userInfo)")

    completionHandler()
  }
}
struct ContentView: View {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

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

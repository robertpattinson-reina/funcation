//
//  FuncationApp.swift
//  Funcation
//
//  Main app entry point.
//  Firebase is configured here, and an AppDelegate wires up the APNs / remote
//  notification hooks that Firebase Phone Authentication relies on.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import UIKit

@main
struct FuncationApp: App {

    // Connect a UIKit AppDelegate so we can forward push notifications and
    // URL callbacks to Firebase Auth (required for phone verification).
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    // Single source of truth for authentication state.
    @StateObject private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Configure Firebase as soon as the app launches.
        FirebaseApp.configure()

        // Apply global navigation bar styling.
        UITabBar.appearance().backgroundColor = UIColor.systemBackground
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.deepBlue)
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.deepBlue)
        ]

        // Register for the silent push that Phone Auth uses to verify the app.
        application.registerForRemoteNotifications()
        return true
    }

    // Forward the APNs device token to Firebase Auth.
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
    }

    // Let Firebase Auth consume its verification push notifications.
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        completionHandler(.newData)
    }

    // Handle the reCAPTCHA URL callback used as a fallback when APNs is unavailable.
    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }
        return false
    }
}

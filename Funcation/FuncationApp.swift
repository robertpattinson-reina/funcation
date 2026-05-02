//
//  FuncationApp.swift
//  Funcation
//
//  Main app entry point.
//  Firebase is initialized here when the app launches,
//  and the user is signed in anonymously if needed.
//

import SwiftUI
import FirebaseCore
import UIKit

@main
struct FuncationApp: App {
    
    init() {
        // Configure Firebase as soon as the app launches.
        FirebaseApp.configure()
        
        // Ensure the app has an authenticated Firebase user.
        AuthService.shared.signInAnonymouslyIfNeeded { result in
            switch result {
            case .success(let userID):
                print("Anonymous auth successful. User ID: \(userID)")
            case .failure(let error):
                print("Anonymous auth failed: \(error.localizedDescription)")
            }
        }
        
        // Apply global app styling.
        UITabBar.appearance().backgroundColor = UIColor.systemBackground
        
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.deepBlue)
        ]
        
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor(AppTheme.deepBlue)
        ]
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

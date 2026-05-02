//
//  AppTheme.swift
//  Funcation
//
//  Centralized visual theme for the app.
//

import SwiftUI

struct AppTheme {
    static let primaryBlue = Color(red: 0.20, green: 0.55, blue: 0.95)
    static let softBlue = Color(red: 0.88, green: 0.94, blue: 1.00)
    static let deepBlue = Color(red: 0.05, green: 0.20, blue: 0.45)
    static let cardBackground = Color(.systemGray6)
    
    // Soft background used across the app for a cleaner, branded look.
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.94, green: 0.98, blue: 1.00),
            Color.white
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // Reusable styling values for cards.
    static let cardCornerRadius: CGFloat = 18
    static let cardShadowRadius: CGFloat = 4
}

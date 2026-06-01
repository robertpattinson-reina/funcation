//
//  AppTheme.swift
//  Funcation
//
//  Centralized visual theme for the app.
//

import SwiftUI

struct AppTheme {
    // Core palette
    static let primaryBlue = Color(red: 0.09, green: 0.44, blue: 0.88)
    static let deepBlue = Color(red: 0.03, green: 0.13, blue: 0.34)
    static let accentCoral = Color(red: 0.97, green: 0.42, blue: 0.27)
    static let softBlue = Color(red: 0.93, green: 0.96, blue: 1.00)
    static let cardBackground = Color.white
    static let pageBackground = Color(red: 0.96, green: 0.97, blue: 0.98)

    // Kept as LinearGradient for API compatibility with Form backgrounds.
    static let backgroundGradient = LinearGradient(
        colors: [pageBackground, pageBackground],
        startPoint: .top,
        endPoint: .bottom
    )

    // Rich gradient for hero header sections.
    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.03, green: 0.13, blue: 0.34),
            Color(red: 0.09, green: 0.36, blue: 0.76)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Card styling
    static let cardCornerRadius: CGFloat = 16
    static let cardShadowRadius: CGFloat = 8
    static let cardShadowColor = Color.black.opacity(0.09)

    // Per-category accent color.
    static func color(for category: SuggestionCategory) -> Color {
        switch category {
        case .lodging:   return Color(red: 0.25, green: 0.60, blue: 0.95)
        case .food:      return Color(red: 0.97, green: 0.55, blue: 0.20)
        case .transport: return Color(red: 0.27, green: 0.76, blue: 0.60)
        case .activity:  return Color(red: 0.75, green: 0.44, blue: 0.96)
        }
    }

    // SF Symbol name for each category.
    static func icon(for category: SuggestionCategory) -> String {
        switch category {
        case .lodging:   return "bed.double.fill"
        case .food:      return "fork.knife"
        case .transport: return "airplane"
        case .activity:  return "ticket.fill"
        }
    }
}

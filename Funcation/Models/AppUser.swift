//
//  AppUser.swift
//  Funcation
//
//  Represents a persistent user account in the application.
//  Accounts are tied to a verified phone number via Firebase Auth.
//

import Foundation

struct AppUser: Identifiable, Codable {

    // Unique user ID (matches the Firebase Auth UID).
    var id: String

    // Display name chosen during profile setup.
    var name: String

    // Verified phone number in E.164 format (e.g. "+15551234567").
    var phoneNumber: String

    // Trips the user belongs to.
    var tripIDs: [String]

    // Account creation date.
    var createdAt: Date
}

//
//  AppUser.swift
//  Funcation
//
//  Represents a user in the application.
//

import Foundation

struct AppUser: Identifiable, Codable {
    
    // Unique user ID
    var id: String
    
    // Display name
    var name: String
    
    // Trips the user belongs to
    var tripIDs: [String]
    
    // Account creation date
    var createdAt: Date
    
}

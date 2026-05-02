//
//  Trip.swift
//  Funcation
//
//  Represents a trip created by a group.
//  This is the main container for suggestions, users, and budgeting.
//

import Foundation

struct Trip: Identifiable, Codable {
    
    // Unique identifier for the trip
    var id: String
    
    // Name of the trip (e.g., "Austin 2026")
    var name: String
    
    // Invite code users use to join
    var inviteCode: String
    
    // Members in the trip
    var members: [String]
    
    // Creation timestamp
    var createdAt: Date
    
}

//
//  Vote.swift
//  Funcation
//
//  Represents one user's vote on one desire.
//  Each user should only have one vote per desire.
//

import Foundation

struct Vote: Identifiable, Codable {
    
    // The vote document ID.
    // We will use the user's ID as the vote ID to prevent duplicate votes.
    var id: String
    
    // Firebase user ID of the person voting.
    var userID: String
    
    // True means Yes, false means No.
    var isYesVote: Bool
    
    // Timestamp for when the vote was submitted.
    var createdAt: Date
}

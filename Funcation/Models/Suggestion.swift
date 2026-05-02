//
//  Suggestion.swift
//  Funcation
//
//  Represents a user suggestion (Desire)
//  such as lodging, food, activity, or transport.
//

import Foundation

struct Suggestion: Identifiable, Codable {
    
    // Unique suggestion ID
    var id: String
    
    // Trip this suggestion belongs to
    var tripID: String
    
    // Title or short description
    var title: String
    
    // Category: lodging, food, transport, activities
    var category: SuggestionCategory
    
    // Estimated cost entered by the user
    var estimatedCost: Double
    
    // Determines whether estimatedCost is for the whole group or per person
    var isPerPerson: Bool
    
    // Optional link (Airbnb, event, etc.)
    var link: String?
    
    // Votes
    var votesYes: Int
    var votesNo: Int
    
    // Creation timestamp
    var createdAt: Date
}

enum SuggestionCategory: String, Codable, CaseIterable {
    case lodging
    case food
    case transport
    case activity
}

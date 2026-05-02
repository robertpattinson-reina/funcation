//
//  FirebaseService.swift
//  Funcation
//
//  Handles Firebase Firestore operations for the app.
//

import Foundation
import FirebaseFirestore

final class FirebaseService {
    
    // Shared singleton instance for simple app-wide access.
    static let shared = FirebaseService()
    
    // Reference to Firestore database.
    private let db = Firestore.firestore()
    
    // Private initializer prevents accidental extra instances.
    private init() {}
    
    /// Saves a trip to Firestore.
    /// - Parameters:
    ///   - trip: The trip object to save.
    ///   - completion: Returns success or failure.
    func saveTrip(_ trip: Trip, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("trips").document(trip.id).setData(from: trip) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Fetches a trip by invite code.
    /// - Parameters:
    ///   - inviteCode: The invite code entered by the user.
    ///   - completion: Returns the matching trip if found.
    func fetchTrip(byInviteCode inviteCode: String, completion: @escaping (Result<Trip, Error>) -> Void) {
        db.collection("trips")
            .whereField("inviteCode", isEqualTo: inviteCode)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    let notFoundError = NSError(
                        domain: "FuncationError",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "No trip found for that invite code."]
                    )
                    completion(.failure(notFoundError))
                    return
                }
                
                do {
                    let trip = try document.data(as: Trip.self)
                    completion(.success(trip))
                } catch {
                    completion(.failure(error))
                }
            }
        
    }
    /// Saves a suggestion inside a trip's desires subcollection.
    func saveSuggestion(_ suggestion: Suggestion, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("trips")
                .document(suggestion.tripID)
                .collection("desires")
                .document(suggestion.id)
                .setData(from: suggestion) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Fetches all desires for a specific trip.
    /// - Parameters:
    ///   - tripID: The trip document ID.
    ///   - completion: Returns an array of saved suggestions.
    func fetchSuggestions(
        for tripID: String,
        completion: @escaping (Result<[Suggestion], Error>) -> Void
    ) {
        db.collection("trips")
            .document(tripID)
            .collection("desires")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let suggestions: [Suggestion] = snapshot?.documents.compactMap { document in
                    try? document.data(as: Suggestion.self)
                } ?? []
                
                completion(.success(suggestions))
            }
    }
    
    /// Saves one user's vote for a specific desire.
    /// The vote document ID is the userID, which prevents duplicate votes
    /// from the same user on the same desire.
    func saveVote(
        tripID: String,
        suggestionID: String,
        vote: Vote,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            try db.collection("trips")
                .document(tripID)
                .collection("desires")
                .document(suggestionID)
                .collection("votes")
                .document(vote.userID)
                .setData(from: vote) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Recalculates vote totals for a desire and updates the parent desire document.
    func updateVoteCounts(
        tripID: String,
        suggestionID: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        db.collection("trips")
            .document(tripID)
            .collection("desires")
            .document(suggestionID)
            .collection("votes")
            .getDocuments { [weak self] snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let votes = snapshot?.documents.compactMap { document in
                    try? document.data(as: Vote.self)
                } ?? []
                
                let yesCount = votes.filter { $0.isYesVote }.count
                let noCount = votes.filter { !$0.isYesVote }.count
                
                self?.db.collection("trips")
                    .document(tripID)
                    .collection("desires")
                    .document(suggestionID)
                    .updateData([
                        "votesYes": yesCount,
                        "votesNo": noCount
                    ]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
            }
    }
    /// Fetches the current user's vote for one suggestion.
    func fetchUserVote(
        tripID: String,
        suggestionID: String,
        userID: String,
        completion: @escaping (Result<Vote?, Error>) -> Void
    ) {
        db.collection("trips")
            .document(tripID)
            .collection("desires")
            .document(suggestionID)
            .collection("votes")
            .document(userID)
            .getDocument { document, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = document,
                      document.exists else {
                    completion(.success(nil))
                    return
                }
                
                do {
                    let vote = try document.data(as: Vote.self)
                    completion(.success(vote))
                } catch {
                    completion(.failure(error))
                }
            }
    }
}

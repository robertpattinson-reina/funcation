//
//  SuggestionViewModel.swift
//  Funcation
//
//  Handles desire/suggestion creation logic.
//  This keeps UI code separate from Firebase write operations.
//

import Foundation
import Combine

class SuggestionViewModel: ObservableObject {
    // Stores the desires loaded from Firebase.
    // Because this is @Published, the UI updates when the list changes.
    @Published var suggestions: [Suggestion] = []
    
    // Stores the current user's vote for each suggestion.
    // Key = suggestionID, Value = true for Yes, false for No.
    @Published var userVotes: [String: Bool] = [:]
    
    /// Creates and saves a new desire/suggestion.
    func addSuggestion(
        tripID: String,
        title: String,
        category: SuggestionCategory,
        estimatedCost: Double,
        isPerPerson: Bool,
        link: String?,
        completion: @escaping (Bool) -> Void
    ) {
        // Remove extra spaces from user input before saving.
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate that the suggestion has a real title.
        guard !trimmedTitle.isEmpty else {
            print("Suggestion title cannot be empty.")
            completion(false)
            return
        }
        
        // Prevent negative cost values.
        guard estimatedCost >= 0 else {
            print("Estimated cost cannot be negative.")
            completion(false)
            return
        }
        
        // Create a new Suggestion object.
        let newSuggestion = Suggestion(
            id: UUID().uuidString,
            tripID: tripID,
            title: trimmedTitle,
            category: category,
            estimatedCost: estimatedCost,
            isPerPerson: isPerPerson,
            link: link,
            votesYes: 0,
            votesNo: 0,
            createdAt: Date()
        )
        
        // Save the suggestion to Firestore.
        FirebaseService.shared.saveSuggestion(newSuggestion) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Suggestion saved successfully.")
                    completion(true)
                case .failure(let error):
                    print("Failed to save suggestion: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
    /// Loads all desires for a specific trip from Firestore.
    func fetchSuggestions(for tripID: String) {
        FirebaseService.shared.fetchSuggestions(for: tripID) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let suggestions):
                    self?.suggestions = suggestions
                    print("Loaded \(suggestions.count) suggestions.")
                    self?.fetchUserVotes(for: tripID)
                    
                case .failure(let error):
                    print("Failed to load suggestions: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Voting

    /// Saves the current user's vote for a desire.
    /// Each user can only have one vote per desire because the vote document ID is the userID.
    func voteOnSuggestion(
        tripID: String,
        suggestionID: String,
        isYesVote: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        // Make sure the user is authenticated before allowing a vote.
        guard let userID = AuthService.shared.currentUserID else {
            print("No authenticated user found. Vote not saved.")
            completion(false)
            return
        }
        
        let vote = Vote(
            id: userID,
            userID: userID,
            isYesVote: isYesVote,
            createdAt: Date()
        )
        
        FirebaseService.shared.saveVote(
            tripID: tripID,
            suggestionID: suggestionID,
            vote: vote
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Vote saved successfully.")
                    
                    // After saving the vote, recalculate the total Yes/No counts.
                    FirebaseService.shared.updateVoteCounts(
                        tripID: tripID,
                        suggestionID: suggestionID
                    ) { countResult in
                        DispatchQueue.main.async {
                            switch countResult {
                            case .success:
                                print("Vote counts updated successfully.")
                                self.fetchSuggestions(for: tripID)
                                completion(true)
                                
                            case .failure(let error):
                                print("Vote saved, but failed to update counts: \(error.localizedDescription)")
                                completion(false)
                            }
                        }
                    }
                case .failure(let error):
                    print("Failed to save vote: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
    
    /// Loads the current user's vote for each suggestion.
    func fetchUserVotes(for tripID: String) {
        guard let userID = AuthService.shared.currentUserID else {
            print("No authenticated user found. Cannot fetch votes.")
            return
        }
        
        for suggestion in suggestions {
            FirebaseService.shared.fetchUserVote(
                tripID: tripID,
                suggestionID: suggestion.id,
                userID: userID
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let vote):
                        if let vote = vote {
                            self?.userVotes[suggestion.id] = vote.isYesVote
                        }
                        
                    case .failure(let error):
                        print("Failed to fetch user vote: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

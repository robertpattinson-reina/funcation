//
//  TripViewModel.swift
//  Funcation
//
//  Handles trip-related business logic.
//  This keeps UI code clean and prepares for Firebase integration.
//

import Foundation
import Combine

class TripViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentTrip: Trip?
    
    // MARK: - Create Trip
    
    /// Creates a new trip and saves it to Firebase.
    /// Calls completion with true only if the save succeeds.
    func createTrip(name: String, completion: @escaping (Bool) -> Void) {

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            print("Invalid trip name.")
            completion(false)
            return
        }

        // Make sure there is an authenticated Firebase user before creating a trip.
        guard let userID = AuthService.shared.currentUserID else {
            print("No authenticated user found.")
            completion(false)
            return
        }

        // Generate invite code
        let inviteCode = InviteCodeGenerator.generateCode()

        // Create trip object with the creator as the first member
        let newTrip = Trip(
            id: UUID().uuidString,
            name: trimmedName,
            inviteCode: inviteCode,
            members: [userID],
            createdAt: Date()
        )

        FirebaseService.shared.saveTrip(newTrip) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.currentTrip = newTrip
                    print("Trip successfully saved to Firestore.")
                    print("Name: \(newTrip.name)")
                    print("Invite Code: \(newTrip.inviteCode)")

                    // Link the trip to the creator's account. Best-effort:
                    // the trip is already saved, so we don't fail on this.
                    UserService.shared.addTrip(tripID: newTrip.id, toUser: userID) { linkResult in
                        if case .failure(let error) = linkResult {
                            print("Trip saved, but failed to link it to the user: \(error.localizedDescription)")
                        }
                    }

                    completion(true)

                case .failure(let error):
                    print("Failed to save trip: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Join Trip
    
    /// Looks up a trip by invite code and loads it if found.
    func joinTrip(inviteCode: String, completion: @escaping (Bool) -> Void) {
        
        let trimmedCode = inviteCode
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        
        guard !trimmedCode.isEmpty else {
            print("Invalid invite code.")
            completion(false)
            return
        }
        
        FirebaseService.shared.fetchTrip(byInviteCode: trimmedCode) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let trip):
                    self?.currentTrip = trip
                    print("Trip successfully loaded from Firestore.")
                    print("Trip Name: \(trip.name)")
                    print("Invite Code: \(trip.inviteCode)")

                    // Register the joiner as a member and link the trip to
                    // their account so it shows up across sessions.
                    if let userID = AuthService.shared.currentUserID {
                        FirebaseService.shared.addMember(userID: userID, toTrip: trip.id) { memberResult in
                            if case .failure(let error) = memberResult {
                                print("Joined trip, but failed to add member: \(error.localizedDescription)")
                            }
                        }
                        UserService.shared.addTrip(tripID: trip.id, toUser: userID) { linkResult in
                            if case .failure(let error) = linkResult {
                                print("Joined trip, but failed to link it to the user: \(error.localizedDescription)")
                            }
                        }
                    }

                    completion(true)

                case .failure(let error):
                    print("Failed to join trip: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }
}

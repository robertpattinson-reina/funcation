//
//  UserService.swift
//  Funcation
//
//  Handles Firestore persistence for user accounts (the `users` collection).
//  A user document is created the first time someone finishes profile setup
//  and is keyed by their Firebase Auth UID so it persists across launches.
//

import Foundation
import FirebaseFirestore

final class UserService {

    // Shared singleton instance for simple app-wide access.
    static let shared = UserService()

    // Reference to Firestore database.
    private let db = Firestore.firestore()

    // Private initializer prevents accidental extra instances.
    private init() {}

    /// Saves (creates or overwrites) a user document.
    func saveUser(_ user: AppUser, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("users").document(user.id).setData(from: user) { error in
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

    /// Fetches a single user by ID. Returns nil if the document doesn't exist yet.
    func fetchUser(id: String, completion: @escaping (Result<AppUser?, Error>) -> Void) {
        db.collection("users").document(id).getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let document = document, document.exists else {
                completion(.success(nil))
                return
            }

            do {
                let user = try document.data(as: AppUser.self)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /// Fetches multiple users by ID, used to resolve trip member names.
    /// Missing or unreadable documents are simply skipped.
    func fetchUsers(ids: [String], completion: @escaping (Result<[AppUser], Error>) -> Void) {
        guard !ids.isEmpty else {
            completion(.success([]))
            return
        }

        let group = DispatchGroup()
        var users: [AppUser] = []
        let lock = NSLock()

        for id in ids {
            group.enter()
            fetchUser(id: id) { result in
                if case .success(let user) = result, let user = user {
                    lock.lock()
                    users.append(user)
                    lock.unlock()
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(.success(users))
        }
    }

    /// Adds a trip ID to a user's list of trips without overwriting existing ones.
    func addTrip(tripID: String, toUser userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("users").document(userID).updateData([
            "tripIDs": FieldValue.arrayUnion([tripID])
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

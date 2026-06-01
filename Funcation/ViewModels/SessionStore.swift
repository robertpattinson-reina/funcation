//
//  SessionStore.swift
//  Funcation
//
//  Single source of truth for the user's authentication state.
//  Drives which top-level screen the app shows: the sign-in flow,
//  profile setup, or the signed-in experience.
//

import Foundation
import Combine

final class SessionStore: ObservableObject {

    /// The high-level state of the current session.
    enum State {
        // Determining auth state on launch.
        case loading
        // No verified user; show the phone sign-in flow.
        case signedOut
        // Phone is verified but no profile/display name exists yet.
        case needsProfile(uid: String, phoneNumber: String)
        // Fully signed in with a persisted account.
        case active(user: AppUser)
    }

    @Published private(set) var state: State = .loading

    init() {
        restoreSession()
    }

    /// Convenience accessor for the signed-in user, if any.
    var currentUser: AppUser? {
        if case .active(let user) = state { return user }
        return nil
    }

    /// On launch, Firebase Auth restores any previous session from the keychain.
    /// If a user is signed in we load their profile; otherwise we show sign-in.
    func restoreSession() {
        guard let uid = AuthService.shared.currentUserID else {
            setState(.signedOut)
            return
        }

        let phoneNumber = AuthService.shared.currentPhoneNumber ?? ""
        loadProfile(uid: uid, phoneNumber: phoneNumber)
    }

    /// Called after a successful SMS code confirmation.
    /// Decides whether the user still needs to set up a profile.
    func handleSignIn(uid: String, phoneNumber: String) {
        loadProfile(uid: uid, phoneNumber: phoneNumber)
    }

    /// Creates and persists the user's account during profile setup.
    func completeProfile(uid: String, phoneNumber: String, name: String, completion: @escaping (Bool) -> Void) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            completion(false)
            return
        }

        let user = AppUser(
            id: uid,
            name: trimmedName,
            phoneNumber: phoneNumber,
            tripIDs: [],
            createdAt: Date()
        )

        UserService.shared.saveUser(user) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.setState(.active(user: user))
                    completion(true)
                case .failure(let error):
                    print("Failed to save user profile: \(error.localizedDescription)")
                    completion(false)
                }
            }
        }
    }

    /// Signs the current user out and returns to the sign-in flow.
    func signOut() {
        do {
            try AuthService.shared.signOut()
        } catch {
            print("Sign out failed: \(error.localizedDescription)")
        }
        setState(.signedOut)
    }

    // MARK: - Helpers

    private func loadProfile(uid: String, phoneNumber: String) {
        UserService.shared.fetchUser(id: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    if let user = user {
                        self?.setState(.active(user: user))
                    } else {
                        self?.setState(.needsProfile(uid: uid, phoneNumber: phoneNumber))
                    }
                case .failure(let error):
                    print("Failed to load profile: \(error.localizedDescription)")
                    // Treat as needing a profile so the user can recover.
                    self?.setState(.needsProfile(uid: uid, phoneNumber: phoneNumber))
                }
            }
        }
    }

    /// Updates published state, always on the main thread.
    private func setState(_ newState: State) {
        if Thread.isMainThread {
            state = newState
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.state = newState
            }
        }
    }
}

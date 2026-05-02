//
//  AuthService.swift
//  Funcation
//
//  Handles Firebase Authentication for the app.
//  For now, this uses anonymous authentication so each user
//  has a stable Firebase user ID without needing a visible login flow.
//

import Foundation
import FirebaseAuth

final class AuthService {
    
    // Shared singleton instance for simple app-wide access.
    static let shared = AuthService()
    
    // Private initializer prevents accidental extra instances.
    private init() {}
    
    /// Ensures that the user is signed in anonymously.
    /// If a user is already signed in, the existing user is reused.
    /// - Parameter completion: Returns the authenticated Firebase user ID.
    func signInAnonymouslyIfNeeded(completion: @escaping (Result<String, Error>) -> Void) {
        
        // If Firebase already has a current user, reuse that identity.
        // This avoids creating duplicate anonymous accounts on relaunch.
        if let currentUser = Auth.auth().currentUser {
            completion(.success(currentUser.uid))
            return
        }
        
        // Otherwise, sign in anonymously.
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                let authError = NSError(
                    domain: "FuncationAuthError",
                    code: 500,
                    userInfo: [NSLocalizedDescriptionKey: "Anonymous authentication succeeded, but no user was returned."]
                )
                completion(.failure(authError))
                return
            }
            
            completion(.success(user.uid))
        }
    }
    
    /// Returns the current Firebase user ID if available.
    var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }
}

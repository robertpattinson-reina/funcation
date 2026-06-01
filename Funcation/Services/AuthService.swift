//
//  AuthService.swift
//  Funcation
//
//  Handles Firebase Phone Authentication for the app.
//  Users verify ownership of a phone number via an SMS code, which gives
//  them a stable, persistent Firebase user ID that survives app relaunches.
//

import Foundation
import FirebaseAuth

final class AuthService {

    // Shared singleton instance for simple app-wide access.
    static let shared = AuthService()

    // Private initializer prevents accidental extra instances.
    private init() {}

    /// Starts phone-number verification by sending an SMS code.
    /// - Parameters:
    ///   - phoneNumber: Phone number in E.164 format (e.g. "+15551234567").
    ///   - completion: Returns a verification ID used to confirm the SMS code.
    func startPhoneVerification(
        phoneNumber: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let verificationID = verificationID else {
                completion(.failure(AuthService.makeError("Verification started, but no verification ID was returned.")))
                return
            }

            completion(.success(verificationID))
        }
    }

    /// Confirms the SMS code and signs the user in.
    /// - Parameters:
    ///   - code: The 6-digit code the user received via SMS.
    ///   - verificationID: The ID returned from `startPhoneVerification`.
    ///   - completion: Returns the authenticated Firebase user ID on success.
    func confirmCode(
        _ code: String,
        verificationID: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = authResult?.user else {
                completion(.failure(AuthService.makeError("Sign-in succeeded, but no user was returned.")))
                return
            }

            completion(.success(user.uid))
        }
    }

    /// Signs the current user out.
    func signOut() throws {
        try Auth.auth().signOut()
    }

    /// Returns the current Firebase user ID if a user is signed in.
    var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    /// The verified phone number of the current user, if available.
    var currentPhoneNumber: String? {
        Auth.auth().currentUser?.phoneNumber
    }

    /// Whether a user is currently signed in.
    var isSignedIn: Bool {
        Auth.auth().currentUser != nil
    }

    /// Builds a domain error with a readable message.
    private static func makeError(_ message: String) -> NSError {
        NSError(
            domain: "FuncationAuthError",
            code: 500,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
    }
}

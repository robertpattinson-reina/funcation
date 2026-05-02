//
//  InviteCodeGenerator.swift
//  Funcation
//
//  Generates short invite codes for trips.
//  These codes are intended to be human-readable and easy to type.
//

import Foundation

struct InviteCodeGenerator {
    
    /// Characters allowed in invite codes.
    /// Ambiguous characters like 0/O and 1/I are intentionally excluded.
    private static let allowedCharacters = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
    
    /// Generates a random invite code of the requested length.
    /// - Parameter length: The desired code length. Default is 6.
    /// - Returns: A random uppercase invite code string.
    static func generateCode(length: Int = 6) -> String {
        guard length > 0 else {
            return ""
        }
        
        var code = ""
        
        for _ in 0..<length {
            if let randomCharacter = allowedCharacters.randomElement() {
                code.append(randomCharacter)
            }
        }
        
        return code
    }
}

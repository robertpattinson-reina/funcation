//
//  PhoneAuthView.swift
//  Funcation
//
//  Sign-in flow. Two phases:
//   1. Enter a phone number -> an SMS verification code is sent.
//   2. Enter the 6-digit code -> the user is signed in.
//

import SwiftUI

struct PhoneAuthView: View {
    @EnvironmentObject private var session: SessionStore

    private enum Phase {
        case enterPhone
        case enterCode
    }

    @State private var phase: Phase = .enterPhone

    // User input.
    @State private var phoneNumber: String = ""
    @State private var code: String = ""

    // Verification state.
    @State private var verificationID: String = ""
    @State private var isWorking: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // MARK: - Hero Header
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 88, height: 88)
                        Image(systemName: "airplane")
                            .font(.system(size: 38, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    Text("Funcation")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Sign in with your phone number to keep your trips.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
                .padding(.bottom, 48)
                .padding(.horizontal)
                .background(AppTheme.heroGradient)

                // MARK: - Card
                VStack(spacing: 16) {
                    switch phase {
                    case .enterPhone: phoneCard
                    case .enterCode: codeCard
                    }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 350, alignment: .top)
                .background(AppTheme.pageBackground)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(AppTheme.pageBackground)
    }

    // MARK: - Phone Entry

    private var phoneCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Your Phone Number", systemImage: "phone.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.deepBlue)

            TextField("+1 555 123 4567", text: $phoneNumber)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
                .textContentType(.telephoneNumber)

            Text("Include your country code, e.g. +1 for the US.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button(action: sendCode) {
                Group {
                    if isWorking {
                        ProgressView()
                    } else {
                        Label("Send Code", systemImage: "paperplane.fill")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accentCoral)
            .disabled(isWorking || phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, y: 4)
    }

    // MARK: - Code Entry

    private var codeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Enter the Code", systemImage: "envelope.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.deepBlue)

            Text("We texted a 6-digit code to \(phoneNumber).")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextField("123456", text: $code)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)

            Button(action: verify) {
                Group {
                    if isWorking {
                        ProgressView()
                    } else {
                        Label("Verify & Continue", systemImage: "checkmark.circle.fill")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accentCoral)
            .disabled(isWorking || code.trimmingCharacters(in: .whitespaces).count < 6)

            Button("Use a different number") {
                phase = .enterPhone
                code = ""
                errorMessage = ""
            }
            .font(.footnote)
            .tint(AppTheme.primaryBlue)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, y: 4)
    }

    // MARK: - Actions

    private func sendCode() {
        let trimmed = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        errorMessage = ""
        isWorking = true

        AuthService.shared.startPhoneVerification(phoneNumber: trimmed) { result in
            DispatchQueue.main.async {
                isWorking = false
                switch result {
                case .success(let id):
                    verificationID = id
                    phase = .enterCode
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func verify() {
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        errorMessage = ""
        isWorking = true

        AuthService.shared.confirmCode(trimmedCode, verificationID: verificationID) { result in
            DispatchQueue.main.async {
                isWorking = false
                switch result {
                case .success(let uid):
                    let phone = AuthService.shared.currentPhoneNumber ?? phoneNumber
                    session.handleSignIn(uid: uid, phoneNumber: phone)
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    PhoneAuthView()
        .environmentObject(SessionStore())
}

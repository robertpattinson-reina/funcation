//
//  ProfileSetupView.swift
//  Funcation
//
//  Shown after phone verification when a user has no profile yet.
//  Collects a display name and creates the persistent account.
//

import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject private var session: SessionStore

    let uid: String
    let phoneNumber: String

    @State private var name: String = ""
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
                        Image(systemName: "person.fill")
                            .font(.system(size: 38, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    Text("Almost there")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("What should your travel buddies call you?")
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
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Display Name", systemImage: "person.text.rectangle.fill")
                            .font(.headline)
                            .foregroundStyle(AppTheme.deepBlue)

                        TextField("e.g. Alex", text: $name)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.name)

                        Button(action: save) {
                            Group {
                                if isWorking {
                                    ProgressView()
                                } else {
                                    Label("Create Account", systemImage: "checkmark.circle.fill")
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.accentCoral)
                        .disabled(isWorking || name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                    .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, y: 4)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 300, alignment: .top)
                .background(AppTheme.pageBackground)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(AppTheme.pageBackground)
    }

    private func save() {
        errorMessage = ""
        isWorking = true

        session.completeProfile(uid: uid, phoneNumber: phoneNumber, name: name) { success in
            isWorking = false
            if !success {
                errorMessage = "Could not create your account. Please try again."
            }
        }
    }
}

#Preview {
    ProfileSetupView(uid: "preview", phoneNumber: "+15551234567")
        .environmentObject(SessionStore())
}

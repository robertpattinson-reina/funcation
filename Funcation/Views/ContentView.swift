//
//  ContentView.swift
//  Funcation
//
//  Root view for the app.
//  Routes between the sign-in flow, profile setup, and the signed-in
//  experience based on the current SessionStore state.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var session: SessionStore

    var body: some View {
        switch session.state {
        case .loading:
            ZStack {
                AppTheme.pageBackground.ignoresSafeArea()
                ProgressView()
            }

        case .signedOut:
            PhoneAuthView()

        case .needsProfile(let uid, let phoneNumber):
            ProfileSetupView(uid: uid, phoneNumber: phoneNumber)

        case .active(let user):
            HomeView(user: user)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionStore())
}

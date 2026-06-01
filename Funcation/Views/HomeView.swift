//
//  HomeView.swift
//  Funcation
//
//  Home / Creation screen.
//  Starting point where users create a new trip or join one with an invite code.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var session: SessionStore

    // The signed-in account.
    let user: AppUser

    @State private var tripName: String = ""
    @State private var inviteCode: String = ""
    @StateObject private var tripViewModel = TripViewModel()
    @State private var navigateToTrip = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Hero Header
                    VStack(spacing: 14) {
                        HStack {
                            Spacer()
                            Button {
                                session.signOut()
                            } label: {
                                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.85))
                            }
                        }

                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.15))
                                .frame(width: 88, height: 88)
                            Image(systemName: "airplane")
                                .font(.system(size: 38, weight: .semibold))
                                .foregroundStyle(.white)
                        }

                        Text("Hi, \(user.name)!")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Group vacation planning, simplified.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 64)
                    .padding(.bottom, 48)
                    .padding(.horizontal)
                    .background(AppTheme.heroGradient)

                    // MARK: - Cards
                    VStack(spacing: 16) {
                        // Create Trip
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Create a Trip", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .foregroundStyle(AppTheme.deepBlue)

                            TextField("Enter trip name", text: $tripName)
                                .textFieldStyle(.roundedBorder)

                            Button(action: {
                                tripViewModel.createTrip(name: tripName) { success in
                                    if success { navigateToTrip = true }
                                }
                            }) {
                                Label("Create Trip", systemImage: "arrow.right.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(AppTheme.accentCoral)
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                        .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, y: 4)

                        // Join Trip
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Join with Invite Code", systemImage: "link.circle.fill")
                                .font(.headline)
                                .foregroundStyle(AppTheme.deepBlue)

                            TextField("Enter invite code", text: $inviteCode)
                                .textFieldStyle(.roundedBorder)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled(true)

                            Button(action: {
                                tripViewModel.joinTrip(inviteCode: inviteCode) { success in
                                    if success { navigateToTrip = true }
                                }
                            }) {
                                Label("Join Trip", systemImage: "person.badge.plus")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(AppTheme.primaryBlue)
                        }
                        .padding()
                        .background(AppTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                        .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, y: 4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 350, alignment: .top)
                    .background(AppTheme.pageBackground)
                }
            }
            .ignoresSafeArea(edges: .top)
            .background(AppTheme.pageBackground)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $navigateToTrip) {
                if let trip = tripViewModel.currentTrip {
                    TripDashboardView(trip: trip)
                }
            }
        }
    }
}

#Preview {
    HomeView(user: AppUser(
        id: "preview",
        name: "Alex",
        phoneNumber: "+15551234567",
        tripIDs: [],
        createdAt: Date()
    ))
    .environmentObject(SessionStore())
}

//
//  HomeView.swift
//  Funcation
//
//  Home / Creation screen.
//  This is the app's starting point, where users can either
//  create a new trip or join an existing one with an invite code.
//

import SwiftUI

struct HomeView: View {
    // MARK: - State Properties

    // Stores the name of a new trip the user wants to create.
    @State private var tripName: String = ""

    // Stores the invite code entered by the user to join a trip.
    @State private var inviteCode: String = ""
    
    @StateObject private var tripViewModel = TripViewModel()
    @State private var navigateToTrip = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - App Header
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.primaryBlue)
                                .frame(width: 82, height: 82)
                                .shadow(radius: AppTheme.cardShadowRadius)
                            
                            Text("F")
                                .font(.system(size: 44, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .rotationEffect(.degrees(-8))
                        }
                        
                        Text("Funcation")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.deepBlue)

                        Text("Making group vacation planning easier.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.primaryBlue)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)

                    // MARK: - Create Trip Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Create a Trip")
                            .font(.headline)
                            .foregroundStyle(AppTheme.deepBlue)

                        TextField("Enter trip name", text: $tripName)
                            .textFieldStyle(.roundedBorder)

                        Button(action: {
                            // Generate a readable invite code for the new trip.
                            tripViewModel.createTrip(name: tripName) { success in
                                if success {
                                    navigateToTrip = true
                                }
                            }
                        }) {
                            Text("Create Trip")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.primaryBlue)
                    }
                    .padding()
                    .background(AppTheme.softBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: AppTheme.cardShadowRadius)

                    // MARK: - Join Trip Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Join with Invite Code")
                            .font(.headline)
                            .foregroundStyle(AppTheme.deepBlue)

                        TextField("Enter invite code", text: $inviteCode)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled(true)

                        Button(action: {
                            tripViewModel.joinTrip(inviteCode: inviteCode) { success in
                                if success {
                                    navigateToTrip = true
                                }
                            }
                        }) {
                            Text("Join Trip")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(AppTheme.primaryBlue)
                    }
                    .padding()
                    .background(AppTheme.softBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: AppTheme.cardShadowRadius)

                    Spacer()
                }
                .padding()
            }
            .background(AppTheme.backgroundGradient)
            .navigationTitle("Home")
            .navigationDestination(isPresented: $navigateToTrip) {
                if let trip = tripViewModel.currentTrip {
                    TripDashboardView(trip: trip)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}

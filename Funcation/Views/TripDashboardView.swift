//
//  TripDashboardView.swift
//  Funcation
//
//  Main dashboard after a trip is created or joined.
//  This screen holds the trip-specific Research, Desires, and Budget tabs.
//

import SwiftUI

struct TripDashboardView: View {
    
    // The active trip passed in from HomeView.
    let trip: Trip
    
    var body: some View {
        TabView {
            
            // MARK: - Research Tab
            ResearchView(trip: trip)
                .tabItem {
                    Label("Research", systemImage: "magnifyingglass")
                }
            
            // MARK: - Desires Tab
            DesiresView(trip: trip)
                .tabItem {
                    Label("Desires", systemImage: "heart.text.square")
                }
            
            // MARK: - Budget Tab
            BudgetView(trip: trip)
                .tabItem {
                    Label("Budget", systemImage: "dollarsign.circle")
                }
        }
        .tint(AppTheme.primaryBlue)
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TripDashboardView(
        trip: Trip(
            id: "1",
            name: "Brazil",
            inviteCode: "ABC123",
            members: [],
            createdAt: Date()
        )
    )
}

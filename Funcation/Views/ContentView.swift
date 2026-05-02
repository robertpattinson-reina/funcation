//
//  ContentView.swift
//  Funcation
//
//  Root view for the app.
//  The app starts at HomeView, where users can create or join a trip.
//  Once inside a trip, TripDashboardView manages the Research, Desires,
//  and Budget tabs.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
}

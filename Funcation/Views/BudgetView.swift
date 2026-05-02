//
//  BudgetView.swift
//  Funcation
//
//  Budget screen.
//  Shows approved desires and calculates total/per-person cost.
//

import SwiftUI

struct BudgetView: View {
    
    // The trip this Budget screen belongs to.
    let trip: Trip
    
    // ViewModel used to fetch desires from Firebase.
    @StateObject private var suggestionViewModel = SuggestionViewModel()
    
    // Approved desires are desires with more Yes votes than No votes.
    private var approvedSuggestions: [Suggestion] {
        suggestionViewModel.suggestions.filter { suggestion in
            suggestion.votesYes > suggestion.votesNo
        }
    }
    
    // Total cost of approved desires.
    private var totalCost: Double {
        let memberCount = max(trip.members.count, 1)
        
        return approvedSuggestions.reduce(0) { total, suggestion in
            if suggestion.isPerPerson {
                return total + (suggestion.estimatedCost * Double(memberCount))
            } else {
                return total + suggestion.estimatedCost
            }
        }
    }
    
    // Per-person estimate based on trip member count.
    private var perPersonCost: Double {
        let memberCount = max(trip.members.count, 1)
        return totalCost / Double(memberCount)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Budget Summary") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Estimated Cost")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("$\(totalCost, specifier: "%.2f")")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(AppTheme.deepBlue)
                        
                        Text("Per-Person Estimate: $\(perPersonCost, specifier: "%.2f")")
                            .foregroundStyle(AppTheme.primaryBlue)
                        
                        Text("Group Members: \(max(trip.members.count, 1))")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }
                
                Section("Approved Desires") {
                    if approvedSuggestions.isEmpty {
                        Text("No approved desires yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(approvedSuggestions) { suggestion in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(suggestion.title)
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.deepBlue)
                                
                                Text(suggestion.category.rawValue.capitalized)
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.primaryBlue)
                                
                                Text(
                                    suggestion.isPerPerson
                                    ? "Estimated Cost: $\(suggestion.estimatedCost, specifier: "%.2f") per person"
                                    : "Estimated Cost: $\(suggestion.estimatedCost, specifier: "%.2f") total"
                                )
                                
                                Text("Yes: \(suggestion.votesYes) | No: \(suggestion.votesNo)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(AppTheme.softBlue)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                            .shadow(radius: AppTheme.cardShadowRadius)
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.backgroundGradient)
            .navigationTitle("Budget")
            .onAppear {
                suggestionViewModel.fetchSuggestions(for: trip.id)
            }
        }
    }
}

#Preview {
    BudgetView(
        trip: Trip(
            id: "1",
            name: "Brazil",
            inviteCode: "ABC123",
            members: ["user1", "user2"],
            createdAt: Date()
        )
    )
}

//
//  BudgetView.swift
//  Funcation
//
//  Budget screen.
//  Shows approved desires and calculates total/per-person cost.
//

import SwiftUI

struct BudgetView: View {
    let trip: Trip
    @StateObject private var suggestionViewModel = SuggestionViewModel()

    private var approvedSuggestions: [Suggestion] {
        suggestionViewModel.suggestions.filter { $0.votesYes > $0.votesNo }
    }

    private var totalCost: Double {
        let memberCount = max(trip.members.count, 1)
        return approvedSuggestions.reduce(0) { total, suggestion in
            suggestion.isPerPerson
                ? total + (suggestion.estimatedCost * Double(memberCount))
                : total + suggestion.estimatedCost
        }
    }

    private var perPersonCost: Double {
        totalCost / Double(max(trip.members.count, 1))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Budget Summary Hero
                    VStack(spacing: 10) {
                        Text("Total Estimated Cost")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.75))

                        Text("$\(totalCost, specifier: "%.2f")")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        HStack(spacing: 20) {
                            Label("$\(perPersonCost, specifier: "%.2f") / person", systemImage: "person.fill")
                            Label("\(max(trip.members.count, 1)) members", systemImage: "person.2.fill")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 32)
                    .padding(.bottom, 36)
                    .padding(.horizontal)
                    .background(AppTheme.heroGradient)

                    // MARK: - Approved Desires List
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Approved Desires", systemImage: "checkmark.seal.fill")
                            .font(.headline)
                            .foregroundStyle(AppTheme.deepBlue)
                            .padding(.horizontal, 4)

                        if approvedSuggestions.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.seal")
                                    .font(.system(size: 40))
                                    .foregroundStyle(AppTheme.primaryBlue.opacity(0.35))
                                Text("Vote on desires to see them here.")
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(approvedSuggestions) { suggestion in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(suggestion.title)
                                                .font(.headline)
                                                .foregroundStyle(AppTheme.deepBlue)

                                            Text(
                                                suggestion.isPerPerson
                                                ? "$\(suggestion.estimatedCost, specifier: "%.2f") / person"
                                                : "$\(suggestion.estimatedCost, specifier: "%.2f") total"
                                            )
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        Label(suggestion.category.rawValue.capitalized,
                                              systemImage: AppTheme.icon(for: suggestion.category))
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(AppTheme.color(for: suggestion.category))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(AppTheme.color(for: suggestion.category).opacity(0.12))
                                            .clipShape(Capsule())
                                    }

                                    HStack(spacing: 16) {
                                        Label("\(suggestion.votesYes) yes", systemImage: "hand.thumbsup.fill")
                                            .font(.caption.weight(.medium))
                                            .foregroundStyle(Color(red: 0.15, green: 0.72, blue: 0.42))
                                        Label("\(suggestion.votesNo) no", systemImage: "hand.thumbsdown.fill")
                                            .font(.caption.weight(.medium))
                                            .foregroundStyle(Color(red: 0.92, green: 0.25, blue: 0.18))
                                    }
                                }
                                .padding()
                                .background(AppTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, y: 3)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 300, alignment: .top)
                    .background(AppTheme.pageBackground)
                }
            }
            .background(AppTheme.pageBackground)
            .navigationTitle("Budget")
            .navigationBarTitleDisplayMode(.inline)
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

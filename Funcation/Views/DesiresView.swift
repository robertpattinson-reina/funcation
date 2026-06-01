//
//  DesiresView.swift
//  Funcation
//
//  Desires screen.
//  Users can add trip suggestions such as lodging, food,
//  transport, or activities.
//

import SwiftUI

struct DesiresView: View {
    let trip: Trip
    @StateObject private var suggestionViewModel = SuggestionViewModel()
    @State private var title: String = ""
    @State private var estimatedCost: String = ""
    @State private var link: String = ""
    @State private var selectedCategory: SuggestionCategory = .activity
    @State private var isPerPerson: Bool = false
    @State private var statusMessage: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(SuggestionCategory.allCases, id: \.self) { category in
                            Label(category.rawValue.capitalized, systemImage: AppTheme.icon(for: category))
                                .tag(category)
                        }
                    }

                    TextField("Estimated cost", text: $estimatedCost)
                        .keyboardType(.decimalPad)

                    Picker("Cost Type", selection: $isPerPerson) {
                        Text("Total").tag(false)
                        Text("Per Person").tag(true)
                    }
                    .pickerStyle(.segmented)

                    TextField("Optional link", text: $link)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    Button("Save Desire") {
                        saveDesire()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accentCoral)
                } header: {
                    Label("Add a Desire", systemImage: "heart.fill")
                        .foregroundStyle(AppTheme.accentCoral)
                }

                Section {
                    if suggestionViewModel.suggestions.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 32))
                                .foregroundStyle(AppTheme.primaryBlue.opacity(0.35))
                            Text("No desires added yet.")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        ForEach(suggestionViewModel.suggestions, id: \.id) { suggestion in
                            desireCard(for: suggestion)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    }
                } header: {
                    Label("Saved Desires", systemImage: "list.heart")
                        .foregroundStyle(AppTheme.primaryBlue)
                }

                if !statusMessage.isEmpty {
                    Section {
                        Text(statusMessage)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.pageBackground)
            .navigationTitle("Desires")
            .onAppear {
                suggestionViewModel.fetchSuggestions(for: trip.id)
            }
        }
    }

    @ViewBuilder
    private func desireCard(for suggestion: Suggestion) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(suggestion.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.deepBlue)

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

            Text(
                suggestion.isPerPerson
                ? "$\(suggestion.estimatedCost, specifier: "%.2f") / person"
                : "$\(suggestion.estimatedCost, specifier: "%.2f") total"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Button {
                    suggestionViewModel.voteOnSuggestion(
                        tripID: trip.id,
                        suggestionID: suggestion.id,
                        isYesVote: true
                    ) { success in
                        statusMessage = success ? "" : "Could not save vote."
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.thumbsup.fill")
                        Text("\(suggestion.votesYes)")
                    }
                    .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(suggestionViewModel.userVotes[suggestion.id] == true
                    ? Color(red: 0.15, green: 0.72, blue: 0.42)
                    : Color(uiColor: .systemGray4))

                Button {
                    suggestionViewModel.voteOnSuggestion(
                        tripID: trip.id,
                        suggestionID: suggestion.id,
                        isYesVote: false
                    ) { success in
                        statusMessage = success ? "" : "Could not save vote."
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.thumbsdown.fill")
                        Text("\(suggestion.votesNo)")
                    }
                    .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(suggestionViewModel.userVotes[suggestion.id] == false
                    ? Color(red: 0.92, green: 0.25, blue: 0.18)
                    : Color(uiColor: .systemGray4))

                Spacer()

                if let link = suggestion.link, let url = URL(string: link) {
                    Link(destination: url) {
                        Image(systemName: "link")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.primaryBlue)
                    }
                }
            }
            .padding(.top, 2)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, y: 3)
    }

    private func saveDesire() {
        let trimmedCost = estimatedCost.trimmingCharacters(in: .whitespacesAndNewlines)
        let cost = PriceParser.parsePrice(trimmedCost)
        let cleanedLink = link.trimmingCharacters(in: .whitespacesAndNewlines)
        let optionalLink = cleanedLink.isEmpty ? nil : cleanedLink

        suggestionViewModel.addSuggestion(
            tripID: trip.id,
            title: title,
            category: selectedCategory,
            estimatedCost: cost,
            isPerPerson: isPerPerson,
            link: optionalLink
        ) { success in
            if success {
                statusMessage = "Desire saved successfully."
                suggestionViewModel.fetchSuggestions(for: trip.id)
                title = ""
                estimatedCost = ""
                link = ""
                selectedCategory = .activity
                isPerPerson = false
            } else {
                statusMessage = "Could not save desire. Please try again."
            }
        }
    }
}

#Preview {
    DesiresView(
        trip: Trip(
            id: "1",
            name: "Brazil",
            inviteCode: "ABC123",
            members: [],
            createdAt: Date()
        )
    )
}

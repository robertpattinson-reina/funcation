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
    
    // The trip this Desires screen belongs to.
    let trip: Trip
    
    // ViewModel handles validation and Firebase saving.
    @StateObject private var suggestionViewModel = SuggestionViewModel()
    
    // Form fields for creating a suggestion.
    @State private var title: String = ""
    @State private var estimatedCost: String = ""
    @State private var link: String = ""
    @State private var selectedCategory: SuggestionCategory = .activity
    @State private var isPerPerson: Bool = false
    
    // Simple user feedback.
    @State private var statusMessage: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Add a Desire") {
                    TextField("Title", text: $title)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(SuggestionCategory.allCases, id: \.self) { category in
                            Text(category.rawValue.capitalized)
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
                    .tint(AppTheme.primaryBlue)
                }
                
                Section("Saved Desires") {
                    if suggestionViewModel.suggestions.isEmpty {
                        Text("No desires added yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(suggestionViewModel.suggestions, id: \.id) { suggestion in
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
                                .font(.subheadline)
                                
                                Text("Yes: \(suggestion.votesYes) | No: \(suggestion.votesNo)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                HStack {
                                    Button("Yes") {
                                        suggestionViewModel.voteOnSuggestion(
                                            tripID: trip.id,
                                            suggestionID: suggestion.id,
                                            isYesVote: true
                                        ) { success in
                                            statusMessage = success ? "Yes vote saved." : "Could not save vote."
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(suggestionViewModel.userVotes[suggestion.id] == true ? AppTheme.primaryBlue : .gray)

                                    Button("No") {
                                        suggestionViewModel.voteOnSuggestion(
                                            tripID: trip.id,
                                            suggestionID: suggestion.id,
                                            isYesVote: false
                                        ) { success in
                                            statusMessage = success ? "No vote saved." : "Could not save vote."
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(suggestionViewModel.userVotes[suggestion.id] == false ? .red : .gray)
                                }
                                .padding(.top, 4)
                                
                                if let link = suggestion.link,
                                   let url = URL(string: link) {
                                    Link("Open Link", destination: url)
                                        .font(.subheadline)
                                }
                            }
                            .padding()
                            .background(AppTheme.softBlue)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                            .shadow(radius: AppTheme.cardShadowRadius)
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                if !statusMessage.isEmpty {
                    Section("Status") {
                        Text(statusMessage)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.backgroundGradient)
            .navigationTitle("Desires")
            .onAppear {
                suggestionViewModel.fetchSuggestions(for: trip.id)
            }
        }
    }
    
    /// Validates form input, converts cost text to a number,
    /// and sends the desire to the ViewModel.
    private func saveDesire() {
        
        let trimmedCost = estimatedCost.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Convert the cost from String to Double.
        // If empty, default to 0. This supports free/unknown-cost items.
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
                
                // Clear form after successful save.
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

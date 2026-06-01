//
//  ResearchView.swift
//  Funcation
//
//  Research tab.
//  Allows users to paste a link, extract basic travel information,
//  and save the result as a Desire.
//

import SwiftUI

struct ResearchView: View {
    let trip: Trip
    @StateObject private var suggestionViewModel = SuggestionViewModel()
    @State private var urlInput: String = ""
    @State private var extractedTitle: String = ""
    @State private var extractedPrice: String = ""
    @State private var extractedLocation: String = ""
    @State private var selectedCategory: SuggestionCategory = .activity
    @State private var statusMessage: String = ""
    @State private var hasExtractedInfo: Bool = false
    @State private var isExtracting: Bool = false
    @State private var showConfirmation: Bool = false
    @State private var isPerPerson: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Enter URL", text: $urlInput)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    Button("Extract Info") {
                        extractInfo()
                    }
                    .disabled(urlInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.accentCoral)

                    if isExtracting {
                        HStack {
                            ProgressView()
                            Text("Extracting travel details...")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Label("Paste a Link", systemImage: "link")
                        .foregroundStyle(AppTheme.primaryBlue)
                }

                Section {
                    if !hasExtractedInfo {
                        Text("No data extracted yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        TextField("Title", text: $extractedTitle)

                        TextField("Price", text: $extractedPrice)
                            .keyboardType(.decimalPad)

                        if extractedPrice.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("Price: Not provided")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        TextField("Location", text: $extractedLocation)

                        if extractedLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("Location: Not provided")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Picker("Cost Type", selection: $isPerPerson) {
                            Text("Total").tag(false)
                            Text("Per Person").tag(true)
                        }
                        .pickerStyle(.segmented)

                        Picker("Category", selection: $selectedCategory) {
                            ForEach(SuggestionCategory.allCases, id: \.self) { category in
                                Label(category.rawValue.capitalized, systemImage: AppTheme.icon(for: category))
                                    .tag(category)
                            }
                        }

                        Button("Add to Desires") {
                            addToDesires()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.primaryBlue)
                    }
                } header: {
                    Label("Extracted Information", systemImage: "sparkles")
                        .foregroundStyle(AppTheme.primaryBlue)
                }

                if !statusMessage.isEmpty {
                    Section {
                        Text(statusMessage)
                            .foregroundStyle(.secondary)
                    }
                }

                if showConfirmation {
                    Section {
                        Label("Added to Desires", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(Color(red: 0.15, green: 0.72, blue: 0.42))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.pageBackground)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Research")
        }
    }

    private func extractInfo() {
        let trimmedURL = urlInput.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedURL.isEmpty else {
            statusMessage = "Please enter a URL."
            return
        }

        isExtracting = true
        statusMessage = "Extracting information..."

        OpenAIService.shared.extractTravelInfo(from: trimmedURL) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let travelInfo):
                    extractedTitle = travelInfo.title
                    extractedPrice = travelInfo.price
                    extractedLocation = travelInfo.location
                    hasExtractedInfo = true
                    isExtracting = false

                    if travelInfo.price.isEmpty {
                        statusMessage = "Price not found. Please enter an estimate."
                    } else {
                        statusMessage = "Information extracted. Review and add to Desires."
                    }

                case .failure(let error):
                    statusMessage = "Extraction failed: \(error.localizedDescription)"
                    isExtracting = false
                }
            }
        }
    }

    private func addToDesires() {
        let cost = PriceParser.parsePrice(extractedPrice)
        let cleanedLink = urlInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedTitle = extractedTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanedTitle.isEmpty else {
            statusMessage = "Please enter a title before adding to Desires."
            return
        }

        suggestionViewModel.addSuggestion(
            tripID: trip.id,
            title: cleanedTitle,
            category: selectedCategory,
            estimatedCost: cost,
            isPerPerson: isPerPerson,
            link: cleanedLink
        ) { success in
            if success {
                statusMessage = "Research item added to Desires."
                isPerPerson = false

                withAnimation {
                    showConfirmation = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        showConfirmation = false
                    }
                }

                urlInput = ""
                extractedTitle = ""
                extractedPrice = ""
                extractedLocation = ""
                selectedCategory = .activity
                hasExtractedInfo = false
            } else {
                statusMessage = "Could not add research item."
            }
        }
    }
}

#Preview {
    ResearchView(
        trip: Trip(
            id: "1",
            name: "Brazil",
            inviteCode: "ABC123",
            members: [],
            createdAt: Date()
        )
    )
}

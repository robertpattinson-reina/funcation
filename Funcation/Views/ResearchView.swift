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
    
    // The active trip this research belongs to.
    let trip: Trip
    
    // ViewModel used to save extracted research as a Desire.
    @StateObject private var suggestionViewModel = SuggestionViewModel()
    
    // User input.
    @State private var urlInput: String = ""
    
    // Extracted placeholder fields.
    @State private var extractedTitle: String = ""
    @State private var extractedPrice: String = ""
    @State private var extractedLocation: String = ""
    
    // User-selected category before saving to Desires.
    @State private var selectedCategory: SuggestionCategory = .activity
    
    // User feedback.
    @State private var statusMessage: String = ""
    
    // Rely on the boolean flag instead of title as a signal.
    @State private var hasExtractedInfo: Bool = false
    
    // For spinner during extraction.
    @State private var isExtracting: Bool = false
    
    // For the confirmation message.
    @State private var showConfirmation: Bool = false
    
    @State private var isPerPerson: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Paste a Link") {
                    TextField("Enter URL", text: $urlInput)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    
                    Button("Extract Info") {
                        extractInfo()
                    }
                    .disabled(urlInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.primaryBlue)
                    
                    if isExtracting {
                        HStack {
                            ProgressView()
                            Text("Extracting travel details...")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section("Extracted Information") {
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
                                Text(category.rawValue.capitalized)
                                    .tag(category)
                            }
                        }
                        
                        Button("Add to Desires") {
                            addToDesires()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.primaryBlue)
                    }
                }
                
                if !statusMessage.isEmpty {
                    Section("Status") {
                        Text(statusMessage)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if showConfirmation {
                    Section {
                        Label("Added to Desires", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.backgroundGradient)
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Research")
        }
    }
    
    /// Uses OpenAI to extract travel information from the pasted URL.
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
    
    /// Saves the extracted research item as a Desire for this trip.
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

                // Show temporary confirmation message.
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

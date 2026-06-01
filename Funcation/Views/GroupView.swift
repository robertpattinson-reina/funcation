//
//  GroupView.swift
//  Funcation
//
//  Group tab.
//  Surfaces the trip's invite code so it can be shared, and lists the
//  members by their display names instead of raw user IDs.
//

import SwiftUI

struct GroupView: View {
    let trip: Trip

    @State private var members: [AppUser] = []
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - Invite Code Card
                    VStack(spacing: 10) {
                        Text("Invite Code")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.75))

                        Text(trip.inviteCode)
                            .font(.system(size: 44, weight: .black, design: .monospaced))
                            .foregroundStyle(.white)
                            .tracking(4)

                        ShareLink(item: "Join my Funcation trip \"\(trip.name)\" with code \(trip.inviteCode)") {
                            Label("Share Invite", systemImage: "square.and.arrow.up")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(.white.opacity(0.18))
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(AppTheme.heroGradient)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                    .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, y: 4)

                    // MARK: - Members
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Members", systemImage: "person.2.fill")
                            .font(.headline)
                            .foregroundStyle(AppTheme.deepBlue)

                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        } else if members.isEmpty {
                            Text("No members yet.")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        } else {
                            ForEach(members) { member in
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.primaryBlue.opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        Text(initials(for: member.name))
                                            .font(.subheadline.weight(.bold))
                                            .foregroundStyle(AppTheme.primaryBlue)
                                    }
                                    Text(member.name)
                                        .font(.body.weight(.medium))
                                        .foregroundStyle(AppTheme.deepBlue)
                                    Spacer()
                                }
                                .padding()
                                .background(AppTheme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                                .shadow(color: AppTheme.cardShadowColor, radius: AppTheme.cardShadowRadius, y: 3)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(AppTheme.pageBackground)
            .navigationTitle("Group")
            .onAppear(perform: loadMembers)
        }
    }

    private func loadMembers() {
        isLoading = true
        UserService.shared.fetchUsers(ids: trip.members) { result in
            isLoading = false
            if case .success(let users) = result {
                // Keep a stable, readable ordering.
                members = users.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            }
        }
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }
}

#Preview {
    GroupView(
        trip: Trip(
            id: "1",
            name: "Brazil",
            inviteCode: "ABC123",
            members: [],
            createdAt: Date()
        )
    )
}

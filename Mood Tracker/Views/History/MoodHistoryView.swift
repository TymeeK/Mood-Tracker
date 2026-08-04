//
//  MoodHistoryView.swift
//  Mood Tracker
//

import SwiftUI
import SwiftData

struct MoodHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if entries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(entries) { entry in
                            entryCard(entry)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        modelContext.delete(entry)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("History")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Text("📔")
                .font(.system(size: 56))
            Text("No Entries Yet")
                .font(.title3.weight(.semibold))
            Text("Entries you save on the Mood tab will show up here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func entryCard(_ entry: MoodEntry) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(entry.emoji)
                .font(.system(size: 34))
                .frame(width: 52, height: 52)
                .background(
                    Circle().fill(MoodStyle.color(for: entry.moodScore).opacity(0.18))
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(entry.moodScore) / 10")
                        .font(.headline)
                    Spacer()
                    Text(entry.date, format: .dateTime.month().day().hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(entry.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(MoodStyle.color(for: entry.moodScore).opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

#Preview {
    MoodHistoryView()
        .modelContainer(for: MoodEntry.self, inMemory: true)
}

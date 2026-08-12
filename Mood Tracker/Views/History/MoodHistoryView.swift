//
//  MoodHistoryView.swift
//  Mood Tracker
//

import SwiftUI
import SwiftData

struct MoodHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]
    @AppStorage("remindersEnabled") private var remindersEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 20
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @State private var viewModel = MoodHistoryViewModel()
    @State private var editingEntry: MoodEntry?
    @State private var pendingDeletionEntry: MoodEntry?
    @State private var isShowingDeleteAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if entries.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 0) {
                        Picker("View", selection: $viewModel.viewMode) {
                            ForEach(MoodHistoryViewModel.ViewMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 4)

                        switch viewModel.viewMode {
                        case .list:
                            List {
                                ForEach(entries) { entry in
                                    entryCard(entry)
                                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            editingEntry = entry
                                        }
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                pendingDeletionEntry = entry
                                                isShowingDeleteAlert = true
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                        case .calendar:
                            MoodCalendarView(entries: entries)
                        }
                    }
                }
            }
            .navigationTitle("History")
            .sheet(item: $editingEntry) { entry in
                EditMoodEntryView(entry: entry)
            }
            .alert(
                "Delete this entry?",
                isPresented: $isShowingDeleteAlert,
                presenting: pendingDeletionEntry
            ) { entry in
                Button("Cancel", role: .cancel) {}
                    .tint(.blue)
                Button("Delete", role: .destructive) {
                    viewModel.delete(
                        entry,
                        context: modelContext,
                        allEntries: entries,
                        remindersEnabled: remindersEnabled,
                        hour: reminderHour,
                        minute: reminderMinute
                    )
                }
            } message: { _ in
                Text("This mood entry will be permanently deleted.")
            }
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
            MoodIconView(score: entry.moodScore, size: 34)
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

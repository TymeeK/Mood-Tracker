//
//  EditMoodEntryView.swift
//  Mood Tracker
//

import SwiftUI
import SwiftData

struct EditMoodEntryView: View {
    @Environment(\.dismiss) private var dismiss

    let entry: MoodEntry

    @State private var viewModel: MoodEntryViewModel
    @FocusState private var summaryFieldFocused: Bool

    init(entry: MoodEntry) {
        self.entry = entry
        _viewModel = State(initialValue: MoodEntryViewModel(entry: entry))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MoodStyle.backgroundGradient(for: viewModel.moodScore)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.4), value: viewModel.moodScore)

                ScrollView {
                    VStack(spacing: 24) {
                        dateLabel

                        MoodHeroCard(moodScore: viewModel.moodScore)

                        MoodScorePicker(moodScore: $viewModel.moodScore)

                        MoodSummaryEditor(summary: $viewModel.summary, isFocused: $summaryFieldFocused)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        summaryFieldFocused = false
                        viewModel.saveEdits()
                        dismiss()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }

    private var dateLabel: some View {
        Text(entry.date, format: .dateTime.weekday(.wide).month().day().year())
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    EditMoodEntryView(entry: MoodEntry(moodScore: 7, summary: "Feeling good today."))
        .modelContainer(for: MoodEntry.self, inMemory: true)
}

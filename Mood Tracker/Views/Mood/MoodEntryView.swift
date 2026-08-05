//
//  MoodEntryView.swift
//  Mood Tracker
//
//  Created by Tymee Kong on 8/2/26.
//

import SwiftUI
import SwiftData

struct MoodEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    @AppStorage("remindersEnabled") private var remindersEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 20
    @AppStorage("reminderMinute") private var reminderMinute = 0

    @State private var viewModel = MoodEntryViewModel()
    @FocusState private var summaryFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                MoodStyle.backgroundGradient(for: viewModel.moodScore)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.4), value: viewModel.moodScore)

                ScrollView {
                    VStack(spacing: 24) {
                        header

                        MoodHeroCard(moodScore: viewModel.moodScore)

                        MoodScorePicker(moodScore: $viewModel.moodScore)

                        MoodSummaryEditor(summary: $viewModel.summary, isFocused: $summaryFieldFocused)

                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }

                if viewModel.showSavedBanner {
                    savedBanner
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        GreetingHeader(title: "How are you feeling?")
    }

    private var saveButton: some View {
        Button {
            summaryFieldFocused = false
            viewModel.save(context: modelContext, existingEntries: entries, remindersEnabled: remindersEnabled, hour: reminderHour, minute: reminderMinute)
        } label: {
            Text("Save")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(MoodStyle.gradient(for: viewModel.moodScore))
                )
        }
        .opacity(viewModel.canSave ? 1 : 0.4)
        .disabled(!viewModel.canSave)
    }

    private var savedBanner: some View {
        VStack {
            Spacer()
            Label("Saved", systemImage: "checkmark.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color.primary.opacity(0.85)))
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

#Preview {
    MoodEntryView()
        .modelContainer(for: MoodEntry.self, inMemory: true)
}

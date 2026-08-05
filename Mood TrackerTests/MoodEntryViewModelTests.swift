//
//  MoodEntryViewModelTests.swift
//  Mood TrackerTests
//

import Testing
import SwiftData
import Foundation
@testable import Mood_Tracker

@MainActor
struct MoodEntryViewModelTests {
    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([MoodEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }

    @Test func canSaveIsFalseWhenSummaryIsBlank() {
        let viewModel = MoodEntryViewModel()
        viewModel.summary = "   \n  "
        #expect(viewModel.canSave == false)
    }

    @Test func canSaveIsTrueWhenSummaryHasContent() {
        let viewModel = MoodEntryViewModel()
        viewModel.summary = "Feeling good today"
        #expect(viewModel.canSave == true)
    }

    @Test func saveInsertsTrimmedEntryIntoContext() throws {
        let context = try makeInMemoryContext()
        let viewModel = MoodEntryViewModel()
        viewModel.moodScore = 9
        viewModel.summary = "  Had a great day  "

        viewModel.save(context: context, existingEntries: [], remindersEnabled: false, hour: 20, minute: 0)

        let saved = try context.fetch(FetchDescriptor<MoodEntry>())
        #expect(saved.count == 1)
        #expect(saved.first?.moodScore == 9)
        #expect(saved.first?.summary == "Had a great day")
    }

    @Test func saveResetsFormAndShowsBanner() throws {
        let context = try makeInMemoryContext()
        let viewModel = MoodEntryViewModel()
        viewModel.moodScore = 2
        viewModel.summary = "Not a great day"

        viewModel.save(context: context, existingEntries: [], remindersEnabled: false, hour: 20, minute: 0)

        #expect(viewModel.moodScore == 5)
        #expect(viewModel.summary == "")
        #expect(viewModel.showSavedBanner == true)
    }

    @Test func initWithEntryPrefillsMoodAndSummary() {
        let entry = MoodEntry(moodScore: 3, summary: "Original summary")

        let viewModel = MoodEntryViewModel(entry: entry)

        #expect(viewModel.moodScore == 3)
        #expect(viewModel.summary == "Original summary")
    }

    @Test func saveEditsAppliesTrimmedChangesBackOntoTheOriginalEntry() {
        let entry = MoodEntry(moodScore: 3, summary: "Original summary")
        let viewModel = MoodEntryViewModel(entry: entry)
        viewModel.moodScore = 8
        viewModel.summary = "  Updated summary  "

        viewModel.saveEdits()

        #expect(entry.moodScore == 8)
        #expect(entry.summary == "Updated summary")
    }

    @Test func saveEditsWithoutAnEntryDoesNothing() {
        let viewModel = MoodEntryViewModel()
        viewModel.summary = "No entry to apply to"

        viewModel.saveEdits()
    }
}

//
//  MoodHistoryViewModelTests.swift
//  Mood TrackerTests
//

import Testing
import SwiftData
import Foundation
@testable import Mood_Tracker

@MainActor
struct MoodHistoryViewModelTests {
    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([MoodEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }

    @Test func viewModeDefaultsToList() {
        let viewModel = MoodHistoryViewModel()
        #expect(viewModel.viewMode == .list)
    }

    @Test func deleteRemovesEntryFromContext() throws {
        let context = try makeInMemoryContext()
        let entry = MoodEntry(moodScore: 5, summary: "Test entry")
        context.insert(entry)
        try context.save()

        let viewModel = MoodHistoryViewModel()
        viewModel.delete(entry, context: context)
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<MoodEntry>())
        #expect(remaining.isEmpty)
    }
}

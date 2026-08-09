//
//  MoodCalendarViewModelTests.swift
//  Mood TrackerTests
//

import Testing
import SwiftData
import Foundation
@testable import Mood_Tracker

@MainActor
struct MoodCalendarViewModelTests {
    private let calendar = Calendar.current

    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([MoodEntry.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }

    private func entry(daysAgo: Int, score: Int) -> MoodEntry {
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
        return MoodEntry(date: date, moodScore: score, summary: "")
    }

    @Test func entriesByDayGroupsEntriesFromTheSameDay() {
        let viewModel = MoodCalendarViewModel()
        let morning = entry(daysAgo: 0, score: 5)
        let laterSameDay = entry(daysAgo: 0, score: 8)
        let yesterday = entry(daysAgo: 1, score: 3)

        let grouped = viewModel.entriesByDay(from: [morning, laterSameDay, yesterday])

        #expect(grouped[calendar.startOfDay(for: Date())]?.count == 2)
        #expect(grouped.count == 2)
    }

    @Test func weekdaySymbolsHasSevenEntriesStartingAtFirstWeekday() {
        let viewModel = MoodCalendarViewModel()
        let symbols = viewModel.weekdaySymbols
        let allSymbols = calendar.veryShortWeekdaySymbols
        #expect(symbols.count == 7)
        #expect(symbols.first == allSymbols[calendar.firstWeekday - 1])
    }

    @Test func monthDatesCountIsMultipleOfSeven() {
        let viewModel = MoodCalendarViewModel()
        #expect(viewModel.monthDates.count % 7 == 0)
    }

    @Test func monthDatesContainsExactlyTheDaysInTheMonth() {
        let viewModel = MoodCalendarViewModel()
        let dayCount = calendar.range(of: .day, in: .month, for: viewModel.displayedMonth)?.count ?? 0
        let nonNilCount = viewModel.monthDates.compactMap { $0 }.count
        #expect(nonNilCount == dayCount)
    }

    @Test func changeMonthMovesDisplayedMonthForward() {
        let viewModel = MoodCalendarViewModel()
        let originalMonth = viewModel.displayedMonth
        viewModel.changeMonth(by: 1)
        let expected = calendar.date(byAdding: .month, value: 1, to: originalMonth)!
        #expect(calendar.isDate(viewModel.displayedMonth, equalTo: expected, toGranularity: .month))
    }

    @Test func changeMonthMovesDisplayedMonthBackward() {
        let viewModel = MoodCalendarViewModel()
        let originalMonth = viewModel.displayedMonth
        viewModel.changeMonth(by: -1)
        let expected = calendar.date(byAdding: .month, value: -1, to: originalMonth)!
        #expect(calendar.isDate(viewModel.displayedMonth, equalTo: expected, toGranularity: .month))
    }

    @Test func toggleSelectionSelectsThenDeselectsSameDate() {
        let viewModel = MoodCalendarViewModel()
        let date = Date()

        viewModel.toggleSelection(for: date)
        #expect(viewModel.selectedDate != nil)

        viewModel.toggleSelection(for: date)
        #expect(viewModel.selectedDate == nil)
    }

    @Test func selectDefaultDateSelectsTodayWhenMostRecentEntryIsToday() {
        let viewModel = MoodCalendarViewModel()
        let today = entry(daysAgo: 0, score: 6)

        viewModel.selectDefaultDateIfNeeded(entries: [today])

        #expect(viewModel.selectedDate != nil)
    }

    @Test func selectDefaultDateStaysNilWhenMostRecentEntryIsNotToday() {
        let viewModel = MoodCalendarViewModel()
        let lastWeek = entry(daysAgo: 7, score: 6)

        viewModel.selectDefaultDateIfNeeded(entries: [lastWeek])

        #expect(viewModel.selectedDate == nil)
    }

    @Test func selectDefaultDateDoesNothingWhenAlreadySelected() {
        let viewModel = MoodCalendarViewModel()
        let manualSelection = calendar.date(byAdding: .day, value: -3, to: Date())!
        viewModel.selectedDate = manualSelection
        let today = entry(daysAgo: 0, score: 6)

        viewModel.selectDefaultDateIfNeeded(entries: [today])

        #expect(calendar.isDate(viewModel.selectedDate!, inSameDayAs: manualSelection))
    }

    @Test func deleteClearsSelectionWhenItWasTheLastEntryForTheDay() throws {
        let context = try makeInMemoryContext()
        let viewModel = MoodCalendarViewModel()
        let onlyEntry = entry(daysAgo: 0, score: 5)
        context.insert(onlyEntry)
        viewModel.selectedDate = Date()

        let allEntries = [onlyEntry]
        let entriesByDay = viewModel.entriesByDay(from: allEntries)
        viewModel.delete(
            onlyEntry,
            context: context,
            entriesByDay: entriesByDay,
            allEntries: allEntries,
            remindersEnabled: false,
            hour: 20,
            minute: 0
        )

        #expect(viewModel.selectedDate == nil)
    }

    @Test func deleteKeepsSelectionWhenOtherEntriesRemainForTheDay() throws {
        let context = try makeInMemoryContext()
        let viewModel = MoodCalendarViewModel()
        let first = entry(daysAgo: 0, score: 5)
        let second = entry(daysAgo: 0, score: 7)
        context.insert(first)
        context.insert(second)
        let selection = Date()
        viewModel.selectedDate = selection

        let allEntries = [first, second]
        let entriesByDay = viewModel.entriesByDay(from: allEntries)
        viewModel.delete(
            first,
            context: context,
            entriesByDay: entriesByDay,
            allEntries: allEntries,
            remindersEnabled: false,
            hour: 20,
            minute: 0
        )

        #expect(viewModel.selectedDate != nil)
    }
}

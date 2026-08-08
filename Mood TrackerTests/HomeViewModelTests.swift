//
//  HomeViewModelTests.swift
//  Mood TrackerTests
//

import Testing
import Foundation
@testable import Mood_Tracker

@MainActor
struct HomeViewModelTests {
    private let calendar = Calendar.current

    private func entry(daysAgo: Int, score: Int) -> MoodEntry {
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
        return MoodEntry(date: date, moodScore: score, summary: "")
    }

    @Test func weekDatesContainsSevenConsecutiveDays() {
        let viewModel = HomeViewModel()
        let dates = viewModel.weekDates
        #expect(dates.count == 7)
        for offset in 1..<dates.count {
            let expected = calendar.date(byAdding: .day, value: 1, to: dates[offset - 1])!
            #expect(calendar.isDate(dates[offset], inSameDayAs: expected))
        }
    }

    @Test func entriesOnDateReturnsAllSameDayEntries() {
        let viewModel = HomeViewModel()
        let todayFirst = entry(daysAgo: 0, score: 7)
        let todaySecond = entry(daysAgo: 0, score: 5)
        let yesterday = entry(daysAgo: 1, score: 3)

        let found = viewModel.entries(on: Date(), in: [todayFirst, todaySecond, yesterday])
        #expect(found.count == 2)
        #expect(found.contains { $0 === todayFirst })
        #expect(found.contains { $0 === todaySecond })
    }

    @Test func entriesOnDateReturnsEmptyWhenNoMatch() {
        let viewModel = HomeViewModel()
        let yesterday = entry(daysAgo: 1, score: 3)

        #expect(viewModel.entries(on: Date(), in: [yesterday]).isEmpty)
    }

    @Test func averageScoreIsNilForEmptyEntries() {
        let viewModel = HomeViewModel()
        #expect(viewModel.averageScore(for: []) == nil)
    }

    @Test func averageScoreRoundsMeanOfEntries() {
        let viewModel = HomeViewModel()
        let entries = [entry(daysAgo: 0, score: 7), entry(daysAgo: 0, score: 4)]
        #expect(viewModel.averageScore(for: entries) == 6)
    }

    @Test func weeklyAverageIsZeroWithNoEntries() {
        let viewModel = HomeViewModel()
        #expect(viewModel.weeklyAverage(from: []) == 0)
    }

    @Test func weeklyAverageComputesMeanOfThisWeeksEntries() {
        let viewModel = HomeViewModel()
        let entries = [entry(daysAgo: 0, score: 8), entry(daysAgo: 1, score: 4)]
        #expect(viewModel.weeklyAverage(from: entries) == 6)
    }

    @Test func weeklyAverageExcludesEntriesOutsideThisWeek() {
        let viewModel = HomeViewModel()
        let inWeek = entry(daysAgo: 0, score: 10)
        let outsideWeek = entry(daysAgo: 30, score: 2)
        #expect(viewModel.weeklyAverage(from: [inWeek, outsideWeek]) == 10)
    }

    @Test func currentStreakIsZeroWithNoEntries() {
        let viewModel = HomeViewModel()
        #expect(viewModel.currentStreak(from: []) == 0)
    }

    @Test func currentStreakCountsConsecutiveLoggedDaysEndingToday() {
        let viewModel = HomeViewModel()
        let entries = (0...2).map { entry(daysAgo: $0, score: 5) }
        #expect(viewModel.currentStreak(from: entries) == 3)
    }

    @Test func currentStreakFallsBackToYesterdayWhenTodayUnlogged() {
        let viewModel = HomeViewModel()
        let entries = (1...3).map { entry(daysAgo: $0, score: 5) }
        #expect(viewModel.currentStreak(from: entries) == 3)
    }

    @Test func currentStreakStopsAtGap() {
        let viewModel = HomeViewModel()
        let entries = [entry(daysAgo: 0, score: 5), entry(daysAgo: 2, score: 5)]
        #expect(viewModel.currentStreak(from: entries) == 1)
    }

    @Test func trendEntriesExcludesOlderThanFourteenDays() {
        let viewModel = HomeViewModel()
        let recent = entry(daysAgo: 5, score: 6)
        let old = entry(daysAgo: 20, score: 2)
        let result = viewModel.trendEntries(from: [old, recent])
        #expect(result.count == 1)
        #expect(result.first === recent)
    }

    @Test func trendEntriesAreSortedAscendingByDate() {
        let viewModel = HomeViewModel()
        let newer = entry(daysAgo: 1, score: 6)
        let older = entry(daysAgo: 3, score: 2)
        let result = viewModel.trendEntries(from: [newer, older])
        #expect(result.count == 2)
        #expect(result.first === older)
        #expect(result.last === newer)
    }
}

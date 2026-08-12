//
//  InsightsViewModelTests.swift
//  Mood TrackerTests
//

import Testing
import Foundation
@testable import Mood_Tracker

@MainActor
struct InsightsViewModelTests {
    private let calendar = Calendar.current

    private func entry(daysAgo: Int, score: Int) -> MoodEntry {
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!
        return MoodEntry(date: date, moodScore: score, summary: "")
    }

    // MARK: - Week navigation

    @Test func weekDatesContainsSevenConsecutiveDays() {
        let viewModel = InsightsViewModel()
        let dates = viewModel.weekDates()
        #expect(dates.count == 7)
        for offset in 1..<dates.count {
            let expected = calendar.date(byAdding: .day, value: 1, to: dates[offset - 1])!
            #expect(calendar.isDate(dates[offset], inSameDayAs: expected))
        }
    }

    @Test func canGoToNextWeekIsFalseAtCurrentWeek() {
        let viewModel = InsightsViewModel()
        #expect(viewModel.canGoToNextWeek() == false)
    }

    @Test func canGoToNextWeekIsTrueAfterGoingBack() {
        let viewModel = InsightsViewModel()
        viewModel.weekOffset = -1
        #expect(viewModel.canGoToNextWeek())
    }

    @Test func canGoToPreviousWeekIsFalseWithNoEntries() {
        let viewModel = InsightsViewModel()
        #expect(viewModel.canGoToPreviousWeek(entries: []) == false)
    }

    @Test func canGoToPreviousWeekIsFalseWhenEarliestEntryIsThisWeek() {
        let viewModel = InsightsViewModel()
        let today = entry(daysAgo: 0, score: 5)
        #expect(viewModel.canGoToPreviousWeek(entries: [today]) == false)
    }

    @Test func canGoToPreviousWeekIsTrueWhenEarliestEntryIsInAnEarlierWeek() {
        let viewModel = InsightsViewModel()
        let old = entry(daysAgo: 30, score: 5)
        #expect(viewModel.canGoToPreviousWeek(entries: [old]))
    }

    @Test func changeWeekMovesOffsetForwardAndBackward() {
        let viewModel = InsightsViewModel()
        viewModel.changeWeek(by: -1)
        #expect(viewModel.weekOffset == -1)
        viewModel.changeWeek(by: 1)
        #expect(viewModel.weekOffset == 0)
    }

    // MARK: - Weekly trend

    @Test func weeklyTrendPointsSkipsDaysWithNoEntries() {
        let viewModel = InsightsViewModel()
        let today = entry(daysAgo: 0, score: 6)
        let points = viewModel.weeklyTrendPoints(from: [today])
        #expect(points.count == 1)
        #expect(points.first?.averageScore == 6)
    }

    @Test func weeklyTrendPointsAveragesMultipleEntriesOnSameDay() {
        let viewModel = InsightsViewModel()
        let morning = entry(daysAgo: 0, score: 8)
        let evening = entry(daysAgo: 0, score: 4)
        let points = viewModel.weeklyTrendPoints(from: [morning, evening])
        #expect(points.count == 1)
        #expect(points.first?.averageScore == 6)
        #expect(points.first?.entries.count == 2)
    }

    @Test func weeklyTrendPointsExcludesEntriesOutsideSelectedWeek() {
        let viewModel = InsightsViewModel()
        let inWeek = entry(daysAgo: 0, score: 6)
        let outsideWeek = entry(daysAgo: 30, score: 2)
        let points = viewModel.weeklyTrendPoints(from: [inWeek, outsideWeek])
        #expect(points.count == 1)
        #expect(calendar.isDate(points[0].date, inSameDayAs: inWeek.date))
    }

    // MARK: - Week stats

    @Test func weekStatsIsEmptyWithNoEntriesThisWeek() {
        let viewModel = InsightsViewModel()
        let stats = viewModel.weekStats(from: [])
        #expect(stats.entriesLogged == 0)
        #expect(stats.average == 0)
        #expect(stats.bestDay == nil)
        #expect(stats.worstDay == nil)
    }

    @Test func weekStatsPicksBestAndWorstDayFromSelectedWeek() {
        let viewModel = InsightsViewModel()
        let best = entry(daysAgo: 0, score: 9)
        let worst = entry(daysAgo: 1, score: 2)
        let middle = entry(daysAgo: 2, score: 5)

        let stats = viewModel.weekStats(from: [best, worst, middle])

        #expect(stats.entriesLogged == 3)
        #expect(stats.bestDay?.averageScore == 9)
        #expect(stats.worstDay?.averageScore == 2)
        #expect(calendar.isDate(stats.bestDay!.date, inSameDayAs: best.date))
        #expect(calendar.isDate(stats.worstDay!.date, inSameDayAs: worst.date))
    }

    @Test func weekStatsComputesAverageAcrossAllEntriesInTheWeek() {
        let viewModel = InsightsViewModel()
        let entries = [entry(daysAgo: 0, score: 8), entry(daysAgo: 1, score: 4)]
        let stats = viewModel.weekStats(from: entries)
        #expect(stats.average == 6)
    }

    // MARK: - Heatmap

    @Test func heatmapDaysReturnsConsecutiveDaysFromStartOfYearThroughToday() {
        let viewModel = InsightsViewModel()
        let days = viewModel.heatmapDays(from: [])
        let yearStart = calendar.dateInterval(of: .year, for: Date())!.start
        let expectedCount = calendar.dateComponents([.day], from: yearStart, to: calendar.startOfDay(for: Date())).day! + 1

        #expect(days.count == expectedCount)
        #expect(calendar.isDate(days.first!.date, inSameDayAs: yearStart))
        #expect(calendar.isDateInToday(days.last!.date))
        for offset in 1..<days.count {
            let expected = calendar.date(byAdding: .day, value: 1, to: days[offset - 1].date)!
            #expect(calendar.isDate(days[offset].date, inSameDayAs: expected))
        }
    }

    @Test func heatmapDaysMarksDaysWithEntriesAndLeavesOthersNil() {
        let viewModel = InsightsViewModel()
        let today = entry(daysAgo: 0, score: 7)
        let days = viewModel.heatmapDays(from: [today])
        #expect(days.last?.averageScore == 7)
        #expect(days.first?.averageScore == nil)
    }

    // MARK: - Longest streak

    @Test func longestStreakIsZeroWithNoEntries() {
        let viewModel = InsightsViewModel()
        #expect(viewModel.longestStreak(from: []) == 0)
    }

    @Test func longestStreakFindsLongestRunAcrossAGapEvenWhenNotOngoing() {
        let viewModel = InsightsViewModel()
        // A 4-day run far in the past, then a gap, then a 2-day run ending today.
        let entries = (10...13).map { entry(daysAgo: $0, score: 5) } + (0...1).map { entry(daysAgo: $0, score: 5) }
        #expect(viewModel.longestStreak(from: entries) == 4)
    }

    @Test func longestStreakCountsOngoingStreakWhenItIsTheLongest() {
        let viewModel = InsightsViewModel()
        let entries = (0...4).map { entry(daysAgo: $0, score: 5) }
        #expect(viewModel.longestStreak(from: entries) == 5)
    }

    // MARK: - Most frequent mood band

    @Test func mostFrequentMoodBandIsNilWithNoRecentEntries() {
        let viewModel = InsightsViewModel()
        #expect(viewModel.mostFrequentMoodBand(from: []) == nil)
    }

    @Test func mostFrequentMoodBandTalliesAcrossBandBoundaries() {
        let viewModel = InsightsViewModel()
        // Three "Happy" (7-8) entries, one "Sad" (3-4) entry.
        let entries = [
            entry(daysAgo: 0, score: 7),
            entry(daysAgo: 1, score: 8),
            entry(daysAgo: 2, score: 7),
            entry(daysAgo: 3, score: 3)
        ]
        let summary = viewModel.mostFrequentMoodBand(from: entries)
        #expect(summary?.label == "Happy")
        #expect(summary?.count == 3)
    }

    @Test func mostFrequentMoodBandExcludesEntriesOlderThanTwelveMonths() {
        let viewModel = InsightsViewModel()
        let recent = entry(daysAgo: 1, score: 3)
        let old = entry(daysAgo: 400, score: 9)
        let summary = viewModel.mostFrequentMoodBand(from: [recent, old])
        #expect(summary?.label == "Sad")
        #expect(summary?.count == 1)
    }

    // MARK: - Total entries

    @Test func totalEntriesCountsOnlyLastTwelveMonths() {
        let viewModel = InsightsViewModel()
        let recent = entry(daysAgo: 5, score: 5)
        let old = entry(daysAgo: 400, score: 5)
        #expect(viewModel.totalEntries(from: [recent, old]) == 1)
    }
}

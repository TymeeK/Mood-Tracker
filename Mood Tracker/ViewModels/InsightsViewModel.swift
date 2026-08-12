//
//  InsightsViewModel.swift
//  Mood Tracker
//

import SwiftUI
import Observation

struct InsightsDayPoint: Identifiable {
    let date: Date
    let averageScore: Int?
    let entries: [MoodEntry]

    var id: Date { date }
}

struct WeekStats {
    let average: Double
    let bestDay: InsightsDayPoint?
    let worstDay: InsightsDayPoint?
    let entriesLogged: Int
}

struct MoodBandSummary {
    let label: String
    let iconName: String
    let count: Int
}

private struct BandTally {
    let iconName: String
    var count: Int = 0
}

@Observable
final class InsightsViewModel {
    private let calendar = Calendar.current

    var weekOffset: Int = 0

    // MARK: - Week navigation

    private func weekInterval(offset: Int) -> DateInterval? {
        guard let currentInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return nil }
        guard let start = calendar.date(byAdding: .weekOfYear, value: offset, to: currentInterval.start),
              let end = calendar.date(byAdding: .weekOfYear, value: offset, to: currentInterval.end) else { return nil }
        return DateInterval(start: start, end: end)
    }

    func weekDates(offset: Int? = nil) -> [Date] {
        guard let interval = weekInterval(offset: offset ?? weekOffset) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }
    }

    func canGoToPreviousWeek(entries: [MoodEntry]) -> Bool {
        guard let earliestDate = entries.map(\.date).min(),
              let interval = weekInterval(offset: weekOffset) else { return false }
        let earliestWeekStart = calendar.dateInterval(of: .weekOfYear, for: earliestDate)?.start ?? earliestDate
        return earliestWeekStart < interval.start
    }

    func canGoToNextWeek() -> Bool {
        weekOffset < 0
    }

    func changeWeek(by value: Int) {
        withAnimation(.snappy(duration: 0.2)) {
            weekOffset += value
        }
    }

    // MARK: - Weekly trend

    private func averageScore(for entries: [MoodEntry]) -> Int? {
        guard !entries.isEmpty else { return nil }
        let total = entries.reduce(0) { $0 + $1.moodScore }
        return Int((Double(total) / Double(entries.count)).rounded())
    }

    /// One point per day in the selected week that has at least one entry;
    /// days with no entries are omitted (same "skip missing days" semantics
    /// used by the Home trend chart) so the line doesn't drop to zero.
    func weeklyTrendPoints(from entries: [MoodEntry]) -> [InsightsDayPoint] {
        let grouped = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }
        return weekDates().compactMap { day in
            let dayEntries = grouped[calendar.startOfDay(for: day)] ?? []
            guard !dayEntries.isEmpty else { return nil }
            return InsightsDayPoint(date: day, averageScore: averageScore(for: dayEntries), entries: dayEntries)
        }
    }

    func weekStats(from entries: [MoodEntry]) -> WeekStats {
        let points = weeklyTrendPoints(from: entries)
        let entriesInWeek = points.flatMap(\.entries)

        let average: Double
        if entriesInWeek.isEmpty {
            average = 0
        } else {
            let total = entriesInWeek.reduce(0) { $0 + $1.moodScore }
            average = Double(total) / Double(entriesInWeek.count)
        }

        let best = points.max { ($0.averageScore ?? 0) < ($1.averageScore ?? 0) }
        let worst = points.min { ($0.averageScore ?? 0) < ($1.averageScore ?? 0) }

        return WeekStats(average: average, bestDay: best, worstDay: worst, entriesLogged: entriesInWeek.count)
    }

    // MARK: - Heatmap (current calendar year)

    /// One point per day from January 1st of the current year through
    /// today; `averageScore` is nil for days with no entries.
    func heatmapDays(from entries: [MoodEntry]) -> [InsightsDayPoint] {
        let today = calendar.startOfDay(for: Date())
        guard let yearStart = calendar.dateInterval(of: .year, for: today)?.start else { return [] }
        let grouped = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }

        var days: [InsightsDayPoint] = []
        var day = yearStart
        while day <= today {
            let dayEntries = grouped[day] ?? []
            days.append(InsightsDayPoint(date: day, averageScore: averageScore(for: dayEntries), entries: dayEntries))
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return days
    }

    // MARK: - Overview stats

    private func recentEntries(from entries: [MoodEntry]) -> [MoodEntry] {
        guard let start = calendar.date(byAdding: .day, value: -365, to: calendar.startOfDay(for: Date())) else { return entries }
        return entries.filter { $0.date >= start }
    }

    func totalEntries(from entries: [MoodEntry]) -> Int {
        recentEntries(from: entries).count
    }

    /// All-time longest run of consecutive logged days, distinct from
    /// `HomeViewModel.currentStreak` which only tracks the ongoing streak.
    func longestStreak(from entries: [MoodEntry]) -> Int {
        let entryDays = Set(entries.map { calendar.startOfDay(for: $0.date) }).sorted()
        guard !entryDays.isEmpty else { return 0 }

        var longest = 1
        var current = 1
        for index in 1..<entryDays.count {
            let previous = entryDays[index - 1]
            let day = entryDays[index]
            if let expected = calendar.date(byAdding: .day, value: 1, to: previous), calendar.isDate(expected, inSameDayAs: day) {
                current += 1
            } else {
                current = 1
            }
            longest = max(longest, current)
        }
        return longest
    }

    func mostFrequentMoodBand(from entries: [MoodEntry]) -> MoodBandSummary? {
        let recent = recentEntries(from: entries)
        guard !recent.isEmpty else { return nil }

        var tallies: [String: BandTally] = [:]
        for entry in recent {
            let label = MoodStyle.label(for: entry.moodScore)
            tallies[label, default: BandTally(iconName: MoodStyle.iconName(for: entry.moodScore))].count += 1
        }

        guard let winner = tallies.max(by: { $0.value.count < $1.value.count }) else { return nil }
        return MoodBandSummary(label: winner.key, iconName: winner.value.iconName, count: winner.value.count)
    }
}

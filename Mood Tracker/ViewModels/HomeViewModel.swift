//
//  HomeViewModel.swift
//  Mood Tracker
//

import Foundation
import Observation

struct MoodTrendPoint: Identifiable {
    let date: Date
    let averageScore: Int

    var id: Date { date }
}

@Observable
final class HomeViewModel {
    private let calendar = Calendar.current

    var weekDates: [Date] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }
    }

    func entries(on date: Date, in entries: [MoodEntry]) -> [MoodEntry] {
        entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func averageScore(for entries: [MoodEntry]) -> Int? {
        guard !entries.isEmpty else { return nil }
        let total = entries.reduce(0) { $0 + $1.moodScore }
        return Int((Double(total) / Double(entries.count)).rounded())
    }

    func thisWeekEntries(from entries: [MoodEntry]) -> [MoodEntry] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
        return entries.filter { interval.contains($0.date) }
    }

    func weeklyAverage(from entries: [MoodEntry]) -> Double {
        let weekEntries = thisWeekEntries(from: entries)
        guard !weekEntries.isEmpty else { return 0 }
        let total = weekEntries.reduce(0) { $0 + $1.moodScore }
        return Double(total) / Double(weekEntries.count)
    }

    func currentStreak(from entries: [MoodEntry]) -> Int {
        let entryDays = Set(entries.map { calendar.startOfDay(for: $0.date) })
        var day = calendar.startOfDay(for: Date())

        // Today doesn't count against the streak until the day is over —
        // fall back to yesterday so an unlogged "today" doesn't zero out
        // an otherwise unbroken streak.
        if !entryDays.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }
            day = yesterday
        }

        var streak = 0
        while entryDays.contains(day) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }

    /// One point per day over the last 14 days, using the averaged score
    /// when a day has multiple entries (same approach as the week strip).
    func trendPoints(from entries: [MoodEntry]) -> [MoodTrendPoint] {
        guard let start = calendar.date(byAdding: .day, value: -13, to: calendar.startOfDay(for: Date())) else { return [] }
        let recent = entries.filter { $0.date >= start }
        let grouped = Dictionary(grouping: recent) { calendar.startOfDay(for: $0.date) }

        return grouped.compactMap { day, dayEntries -> MoodTrendPoint? in
            guard let average = averageScore(for: dayEntries) else { return nil }
            return MoodTrendPoint(date: day, averageScore: average)
        }
        .sorted { $0.date < $1.date }
    }

    func scheduleRemindersIfNeeded(remindersEnabled: Bool, hour: Int, minute: Int, entries: [MoodEntry]) {
        guard remindersEnabled else { return }
        NotificationScheduler.refreshSchedule(hour: hour, minute: minute, entries: entries)
    }
}

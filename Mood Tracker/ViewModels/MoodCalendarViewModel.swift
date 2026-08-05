//
//  MoodCalendarViewModel.swift
//  Mood Tracker
//

import SwiftUI
import SwiftData
import Observation

@Observable
final class MoodCalendarViewModel {
    var displayedMonth: Date = Date()
    var selectedDate: Date?

    private let calendar = Calendar.current

    func entriesByDay(from entries: [MoodEntry]) -> [Date: [MoodEntry]] {
        Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }
    }

    var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return Array(symbols[start...] + symbols[..<start])
    }

    var monthDates: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }
        let firstOfMonth = monthInterval.start

        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmptyCount = (weekdayOfFirst - calendar.firstWeekday + 7) % 7

        let dayCount = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 0

        var dates: [Date?] = Array(repeating: nil, count: leadingEmptyCount)
        dates += (0..<dayCount).compactMap { calendar.date(byAdding: .day, value: $0, to: firstOfMonth) }
        while dates.count % 7 != 0 { dates.append(nil) }
        return dates
    }

    func changeMonth(by value: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        withAnimation(.snappy(duration: 0.2)) {
            displayedMonth = newMonth
        }
    }

    func toggleSelection(for date: Date) {
        let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false
        withAnimation(.snappy(duration: 0.2)) {
            selectedDate = isSelected ? nil : date
        }
    }

    func selectDefaultDateIfNeeded(entries: [MoodEntry]) {
        guard selectedDate == nil, let mostRecent = entries.first?.date else { return }
        selectedDate = calendar.isDateInToday(mostRecent) ? mostRecent : nil
    }

    func delete(_ entry: MoodEntry, context: ModelContext, entriesByDay: [Date: [MoodEntry]]) {
        let day = calendar.startOfDay(for: entry.date)
        let isLastEntryForDay = entriesByDay[day]?.count == 1
        context.delete(entry)
        if isLastEntryForDay {
            selectedDate = nil
        }
    }
}

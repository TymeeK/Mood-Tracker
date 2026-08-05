//
//  MoodCalendarView.swift
//  Mood Tracker
//

import SwiftUI
import SwiftData

struct MoodCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    let entries: [MoodEntry]

    @State private var displayedMonth: Date = Date()
    @State private var selectedDate: Date?

    private let calendar = Calendar.current
    private let accent = MoodStyle.color(for: 8)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                monthCard
                if let selectedDate, let dayEntries = entriesByDay[calendar.startOfDay(for: selectedDate)] {
                    selectedDaySection(date: selectedDate, dayEntries: dayEntries)
                }
            }
            .padding(20)
        }
        .onAppear {
            if selectedDate == nil, let mostRecent = entries.first?.date {
                selectedDate = calendar.isDateInToday(mostRecent) ? mostRecent : nil
            }
        }
    }

    // MARK: - Month card

    private var monthCard: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(displayedMonth, format: .dateTime.month(.wide).year())
                    .font(.headline)

                Spacer()

                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(.primary)

            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(Array(monthDates.enumerated()), id: \.offset) { _, date in
                    dayCell(date)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.background)
        )
    }

    private func dayCell(_ date: Date?) -> some View {
        Group {
            if let date {
                let isToday = calendar.isDateInToday(date)
                let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false
                let hasEntry = entriesByDay[calendar.startOfDay(for: date)] != nil

                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        selectedDate = isSelected ? nil : date
                    }
                } label: {
                    VStack(spacing: 5) {
                        Text("\(calendar.component(.day, from: date))")
                            .font(.subheadline.weight(isToday ? .bold : .regular))
                            .foregroundStyle(isToday ? accent : .primary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle().fill(isSelected ? accent.opacity(0.18) : Color.clear)
                            )
                            .overlay(
                                Circle().strokeBorder(isToday ? accent : .clear, lineWidth: 1.5)
                            )

                        Circle()
                            .fill(hasEntry ? accent : Color.clear)
                            .frame(width: 6, height: 6)
                    }
                }
                .buttonStyle(.plain)
                .disabled(!hasEntry)
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44)
    }

    // MARK: - Selected day detail

    private func selectedDaySection(date: Date, dayEntries: [MoodEntry]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(date, format: .dateTime.weekday(.wide).month().day())
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                ForEach(dayEntries) { entry in
                    entryRow(entry)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.background)
        )
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private func entryRow(_ entry: MoodEntry) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(entry.emoji)
                .font(.system(size: 30))
                .frame(width: 46, height: 46)
                .background(
                    Circle().fill(MoodStyle.color(for: entry.moodScore).opacity(0.18))
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(entry.moodScore) / 10")
                        .font(.headline)
                    Spacer()
                    Text(entry.date, format: .dateTime.hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(entry.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                deleteEntry(entry)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func deleteEntry(_ entry: MoodEntry) {
        let day = calendar.startOfDay(for: entry.date)
        let isLastEntryForDay = entriesByDay[day]?.count == 1
        modelContext.delete(entry)
        if isLastEntryForDay {
            selectedDate = nil
        }
    }

    // MARK: - Data helpers

    private var entriesByDay: [Date: [MoodEntry]] {
        Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return Array(symbols[start...] + symbols[..<start])
    }

    private var monthDates: [Date?] {
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

    private func changeMonth(by value: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) else { return }
        withAnimation(.snappy(duration: 0.2)) {
            displayedMonth = newMonth
        }
    }
}

#Preview {
    MoodCalendarView(entries: [])
        .modelContainer(for: MoodEntry.self, inMemory: true)
}

//
//  MoodCalendarView.swift
//  Mood Tracker
//

import SwiftUI
import SwiftData

struct MoodCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    let entries: [MoodEntry]

    @State private var viewModel = MoodCalendarViewModel()
    @State private var editingEntry: MoodEntry?
    @State private var pendingDeletionEntry: MoodEntry?
    @State private var isShowingDeleteAlert = false

    private let calendar = Calendar.current
    private let accent = MoodStyle.color(for: 8)

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                monthCard
                if let selectedDate = viewModel.selectedDate, let dayEntries = entriesByDay[calendar.startOfDay(for: selectedDate)] {
                    selectedDaySection(date: selectedDate, dayEntries: dayEntries)
                }
            }
            .padding(20)
        }
        .onAppear {
            viewModel.selectDefaultDateIfNeeded(entries: entries)
        }
        .sheet(item: $editingEntry) { entry in
            EditMoodEntryView(entry: entry)
        }
        .alert(
            "Delete this entry?",
            isPresented: $isShowingDeleteAlert,
            presenting: pendingDeletionEntry
        ) { entry in
            Button("Cancel", role: .cancel) {}
                .tint(.blue)
            Button("Delete", role: .destructive) {
                viewModel.delete(entry, context: modelContext, entriesByDay: entriesByDay)
            }
        } message: { _ in
            Text("This mood entry will be permanently deleted.")
        }
    }

    // MARK: - Month card

    private var monthCard: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    viewModel.changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(viewModel.displayedMonth, format: .dateTime.month(.wide).year())
                    .font(.headline)

                Spacer()

                Button {
                    viewModel.changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundStyle(.primary)

            HStack(spacing: 0) {
                ForEach(viewModel.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(Array(viewModel.monthDates.enumerated()), id: \.offset) { _, date in
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
                let isSelected = viewModel.selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false
                let hasEntry = entriesByDay[calendar.startOfDay(for: date)] != nil

                Button {
                    viewModel.toggleSelection(for: date)
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
        .contentShape(Rectangle())
        .onTapGesture {
            editingEntry = entry
        }
        .contextMenu {
            Button {
                editingEntry = entry
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                pendingDeletionEntry = entry
                isShowingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Data helpers

    private var entriesByDay: [Date: [MoodEntry]] {
        viewModel.entriesByDay(from: entries)
    }
}

#Preview {
    MoodCalendarView(entries: [])
        .modelContainer(for: MoodEntry.self, inMemory: true)
}

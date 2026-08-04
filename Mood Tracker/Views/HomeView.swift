//
//  HomeView.swift
//  Mood Tracker
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var selectedTab: MainTabView.Tab
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        reflectButton

                        if entries.isEmpty {
                            emptyState
                        } else {
                            weekCard
                            statsRow
                            recentSection
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(MoodStyle.greeting())
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("How is your mood today?")
                .font(.title2.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var reflectButton: some View {
        Button {
            selectedTab = .mood
        } label: {
            HStack {
                Text("Reflect your emotion")
                    .font(.headline)
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                Capsule().fill(MoodStyle.gradient(for: 8))
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text("🌤️")
                .font(.system(size: 48))
            Text("No entries yet")
                .font(.headline)
            Text("Log your first mood to start building your summary here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.background)
        )
    }

    // MARK: - This week

    private var weekDates: [Date] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: interval.start) }
    }

    private func entry(on date: Date) -> MoodEntry? {
        entries.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private var weekCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("This Week")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                ForEach(weekDates, id: \.self) { date in
                    let dayEntry = entry(on: date)
                    let isToday = calendar.isDateInToday(date)

                    VStack(spacing: 6) {
                        Text(date, format: .dateTime.weekday(.narrow))
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        ZStack {
                            Circle()
                                .fill(dayEntry != nil ? MoodStyle.color(for: dayEntry!.moodScore).opacity(0.2) : Color(.tertiarySystemFill))
                                .frame(width: 34, height: 34)

                            if let dayEntry {
                                Text(dayEntry.emoji)
                                    .font(.system(size: 16))
                            }
                        }
                        .overlay(
                            Circle()
                                .strokeBorder(isToday ? MoodStyle.color(for: 8) : .clear, lineWidth: 2)
                                .frame(width: 34, height: 34)
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.background)
        )
    }

    // MARK: - Stats

    private var thisWeekEntries: [MoodEntry] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return [] }
        return entries.filter { interval.contains($0.date) }
    }

    private var weeklyAverage: Double {
        guard !thisWeekEntries.isEmpty else { return 0 }
        let total = thisWeekEntries.reduce(0) { $0 + $1.moodScore }
        return Double(total) / Double(thisWeekEntries.count)
    }

    private var currentStreak: Int {
        var streak = 0
        var day = calendar.startOfDay(for: Date())
        let entryDays = Set(entries.map { calendar.startOfDay(for: $0.date) })
        while entryDays.contains(day) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(
                title: "Weekly Average",
                value: weeklyAverage > 0 ? String(format: "%.1f", weeklyAverage) : "–",
                accent: weeklyAverage > 0 ? MoodStyle.color(for: Int(weeklyAverage.rounded())) : .secondary
            ) {
                GeometryReader { geo in
                    Capsule()
                        .fill(Color(.tertiarySystemFill))
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(MoodStyle.gradient(for: Int(weeklyAverage.rounded())))
                                .frame(width: geo.size.width * (weeklyAverage / 10))
                        }
                }
                .frame(height: 8)
            }

            statCard(
                title: "Day Streak",
                value: "\(currentStreak)",
                accent: MoodStyle.color(for: 8)
            ) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(MoodStyle.color(for: 8))
                    Text(currentStreak == 1 ? "day" : "days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func statCard<Content: View>(title: String, value: String, accent: Color, @ViewBuilder footer: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title.weight(.bold))
                .foregroundStyle(accent)
            footer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
        )
    }

    // MARK: - Recent entries

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    selectedTab = .history
                } label: {
                    Text("See All")
                        .font(.caption.weight(.semibold))
                }
            }

            VStack(spacing: 10) {
                ForEach(entries.prefix(3)) { entry in
                    HStack(spacing: 12) {
                        Text(entry.emoji)
                            .font(.system(size: 24))
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(MoodStyle.color(for: entry.moodScore).opacity(0.18)))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.summary)
                                .font(.subheadline)
                                .lineLimit(1)
                            Text(entry.date, format: .dateTime.month().day())
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(entry.moodScore)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(MoodStyle.color(for: entry.moodScore))
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.background)
        )
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .modelContainer(for: MoodEntry.self, inMemory: true)
}

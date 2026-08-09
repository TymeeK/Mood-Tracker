//
//  HomeView.swift
//  Mood Tracker
//

import SwiftUI
import SwiftData
import Charts

struct HomeView: View {
    @Binding var selectedTab: MainTabView.Tab
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    @AppStorage("remindersEnabled") private var remindersEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 20
    @AppStorage("reminderMinute") private var reminderMinute = 0

    @State private var viewModel = HomeViewModel()

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
                            trendSection
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            viewModel.scheduleRemindersIfNeeded(remindersEnabled: remindersEnabled, hour: reminderHour, minute: reminderMinute, entries: entries)
        }
    }

    // MARK: - Header

    private var header: some View {
        GreetingHeader(title: "How is your mood today?")
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

    private var weekCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("This Week")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                ForEach(viewModel.weekDates, id: \.self) { date in
                    let dayEntries = viewModel.entries(on: date, in: entries)
                    let averageScore = viewModel.averageScore(for: dayEntries)
                    let isToday = Calendar.current.isDateInToday(date)

                    VStack(spacing: 6) {
                        Text(date, format: .dateTime.weekday(.narrow))
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        ZStack {
                            Circle()
                                .fill(averageScore != nil ? MoodStyle.color(for: averageScore!).opacity(0.2) : Color(.tertiarySystemFill))
                                .frame(width: 34, height: 34)

                            if let averageScore {
                                Text(MoodStyle.emoji(for: averageScore))
                                    .font(.system(size: 16))
                            }
                        }
                        .overlay(
                            Circle()
                                .strokeBorder(isToday ? MoodStyle.color(for: 8) : .clear, lineWidth: 2)
                                .frame(width: 34, height: 34)
                        )
                        .overlay(alignment: .topTrailing) {
                            if dayEntries.count > 1 {
                                Text("\(dayEntries.count)")
                                    .font(.system(size: 9).weight(.bold))
                                    .foregroundStyle(MoodStyle.color(for: 8))
                                    .frame(width: 14, height: 14)
                                    .background(
                                        Circle()
                                            .fill(Color(.systemBackground))
                                            .overlay(Circle().strokeBorder(MoodStyle.color(for: 8), lineWidth: 1))
                                    )
                                    .offset(x: 4, y: -4)
                            }
                        }
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

    private var statsRow: some View {
        let weeklyAverage = viewModel.weeklyAverage(from: entries)
        let currentStreak = viewModel.currentStreak(from: entries)

        return HStack(spacing: 12) {
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
                title: "Current Streak",
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

    // MARK: - Trend

    private var trendSection: some View {
        let trendPoints = viewModel.trendPoints(from: entries)

        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Trend")
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

            if trendPoints.count < 2 {
                Text("Log a few more moods to see your trend.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                Chart(trendPoints) { point in
                    LineMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Mood", point.averageScore)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(MoodStyle.gradient(for: 8))
                    .symbol {
                        Circle()
                            .fill(MoodStyle.color(for: point.averageScore))
                            .frame(width: 6, height: 6)
                    }

                    AreaMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Mood", point.averageScore)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(MoodStyle.gradient(for: 8).opacity(0.15))
                }
                .chartYScale(domain: 0...10)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, 5, 10])
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 3)) { _ in
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .frame(height: 160)
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

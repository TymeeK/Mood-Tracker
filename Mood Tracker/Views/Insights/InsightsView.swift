//
//  InsightsView.swift
//  Mood Tracker
//

import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    @State private var viewModel = InsightsViewModel()
    @State private var selectedDetail: InsightsDayPoint?

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if entries.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            weekNavigator
                            trendCard
                            weekStatsRow

                            if let selectedDetail {
                                detailCard(selectedDetail)
                            }

                            heatmapCard
                            overviewStatsRow
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Insights")
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text("📊")
                .font(.system(size: 48))
            Text("No entries yet")
                .font(.headline)
            Text("Log your first mood to start seeing insights here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }

    // MARK: - Week navigator

    private var weekNavigator: some View {
        HStack {
            Button {
                viewModel.changeWeek(by: -1)
                selectedDetail = nil
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(!viewModel.canGoToPreviousWeek(entries: entries))

            Spacer()

            if let firstDay = viewModel.weekDates().first {
                Text(weekLabel(for: firstDay))
                    .font(.headline)
            }

            Spacer()

            Button {
                viewModel.changeWeek(by: 1)
                selectedDetail = nil
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(!viewModel.canGoToNextWeek())
        }
        .foregroundStyle(.primary)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.background)
        )
    }

    private func weekLabel(for date: Date) -> String {
        viewModel.weekOffset == 0 ? "This Week" : "Week of \(date.formatted(.dateTime.month().day()))"
    }

    // MARK: - Weekly trend

    private var trendCard: some View {
        let points = viewModel.weeklyTrendPoints(from: entries)

        return VStack(alignment: .leading, spacing: 14) {
            Text("Mood Trend")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            if points.isEmpty {
                Text("No entries logged this week.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                Chart(points) { point in
                    LineMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Mood", point.averageScore ?? 0)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(MoodStyle.gradient(for: 8))
                    .symbol {
                        Circle()
                            .fill(MoodStyle.color(for: point.averageScore ?? 0))
                            .frame(width: 6, height: 6)
                    }

                    AreaMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Mood", point.averageScore ?? 0)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(MoodStyle.gradient(for: 8).opacity(0.15))

                    if let selectedDetail, calendar.isDate(selectedDetail.date, inSameDayAs: point.date) {
                        PointMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("Mood", point.averageScore ?? 0)
                        )
                        .foregroundStyle(MoodStyle.color(for: point.averageScore ?? 0))
                        .symbolSize(120)
                    }
                }
                .chartYScale(domain: 0...10)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, 5, 10])
                }
                .chartXAxis {
                    AxisMarks(values: points.map(\.date)) { _ in
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .frame(height: 160)
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let origin = geometry[proxy.plotAreaFrame].origin
                                        let x = value.location.x - origin.x
                                        guard let date: Date = proxy.value(atX: x) else { return }
                                        selectedDetail = nearestPoint(to: date, in: points)
                                    }
                            )
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

    private func nearestPoint(to date: Date, in points: [InsightsDayPoint]) -> InsightsDayPoint? {
        points.min { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }
    }

    // MARK: - This week stats

    private var weekStatsRow: some View {
        let stats = viewModel.weekStats(from: entries)

        return HStack(spacing: 12) {
            statTile(
                title: "Weekly Average",
                value: stats.entriesLogged > 0 ? String(format: "%.1f", stats.average) : "–",
                accent: stats.entriesLogged > 0 ? MoodStyle.color(for: Int(stats.average.rounded())) : .secondary
            )

            statTile(
                title: "Best Day",
                value: stats.bestDay.map { $0.date.formatted(.dateTime.weekday(.abbreviated)) } ?? "–",
                accent: stats.bestDay?.averageScore.map { MoodStyle.color(for: $0) } ?? .secondary
            )
            .onTapGesture {
                if let bestDay = stats.bestDay { selectedDetail = bestDay }
            }

            statTile(
                title: "Worst Day",
                value: stats.worstDay.map { $0.date.formatted(.dateTime.weekday(.abbreviated)) } ?? "–",
                accent: stats.worstDay?.averageScore.map { MoodStyle.color(for: $0) } ?? .secondary
            )
            .onTapGesture {
                if let worstDay = stats.worstDay { selectedDetail = worstDay }
            }
        }
    }

    private func statTile(title: String, value: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.background)
        )
    }

    // MARK: - Inline detail card

    private func detailCard(_ point: InsightsDayPoint) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(point.date, format: .dateTime.weekday(.wide).month().day())
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    selectedDetail = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            if point.entries.isEmpty {
                Text("No entry logged this day.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 10) {
                    ForEach(point.entries) { entry in
                        HStack(alignment: .top, spacing: 14) {
                            MoodIconView(score: entry.moodScore, size: 30)
                                .frame(width: 46, height: 46)
                                .background(
                                    Circle().fill(MoodStyle.color(for: entry.moodScore).opacity(0.18))
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(entry.moodScore) / 10")
                                    .font(.headline)
                                Text(entry.summary.isEmpty ? "No summary" : entry.summary)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
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

    // MARK: - Heatmap

    private var heatmapCard: some View {
        let days = viewModel.heatmapDays(from: entries)
        let columns = Swift.stride(from: 0, to: days.count, by: 7).map { start in
            Array(days[start..<min(start + 7, days.count)])
        }
        let monthLabels = monthLabels(for: columns)

        return VStack(alignment: .leading, spacing: 14) {
            Text("Mood Heatmap · \(calendar.component(.year, from: Date()).formatted(.number.grouping(.never)))")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top, spacing: 3) {
                        ForEach(Array(columns.enumerated()), id: \.offset) { _, column in
                            VStack(spacing: 3) {
                                ForEach(column) { day in
                                    heatmapCell(day)
                                }
                            }
                        }
                    }

                    HStack(alignment: .top, spacing: 3) {
                        ForEach(Array(monthLabels.enumerated()), id: \.offset) { _, label in
                            Text(label ?? "")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .fixedSize()
                                .frame(width: 10, alignment: .leading)
                        }
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

    private func heatmapCell(_ day: InsightsDayPoint) -> some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(day.averageScore.map { MoodStyle.color(for: $0) } ?? Color(.tertiarySystemFill))
            .frame(width: 10, height: 10)
    }

    /// One label per heatmap column: the month's abbreviation on the first
    /// column where that month appears, nil for every column after (so the
    /// label row stays aligned with the grid above it without repeating).
    private func monthLabels(for columns: [[InsightsDayPoint]]) -> [String?] {
        var labels: [String?] = []
        var lastMonth: Int?
        for column in columns {
            guard let firstDay = column.first?.date else {
                labels.append(nil)
                continue
            }
            let month = calendar.component(.month, from: firstDay)
            if month != lastMonth {
                labels.append(firstDay.formatted(.dateTime.month(.abbreviated)))
                lastMonth = month
            } else {
                labels.append(nil)
            }
        }
        return labels
    }

    // MARK: - Overview stats

    private var overviewStatsRow: some View {
        let totalEntries = viewModel.totalEntries(from: entries)
        let longestStreak = viewModel.longestStreak(from: entries)
        let topBand = viewModel.mostFrequentMoodBand(from: entries)

        return HStack(spacing: 12) {
            statTile(title: "Total Entries", value: "\(totalEntries)", accent: MoodStyle.color(for: 8))
            statTile(
                title: "Longest Streak",
                value: "\(longestStreak) \(longestStreak == 1 ? "day" : "days")",
                accent: MoodStyle.color(for: 8)
            )
            moodBandTile(topBand)
        }
    }

    private func moodBandTile(_ band: MoodBandSummary?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Most Frequent Mood")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 6) {
                if let band {
                    Image(band.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                    Text(band.label)
                        .font(.title3.weight(.bold))
                } else {
                    Text("–")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.background)
        )
    }
}

#Preview {
    InsightsView()
        .modelContainer(for: MoodEntry.self, inMemory: true)
}

//
//  SampleData.swift
//  Mood Tracker
//
//  Debug-only helper for populating the app with realistic sample
//  entries while testing the Home hub and History views.
//

#if DEBUG
import Foundation
import SwiftData

enum SampleData {
    private static let entries: [(daysAgo: Int, score: Int, summary: String)] = [
        (6, 6, "Kept busy with work, feeling pretty steady overall."),
        (5, 8, "Had a great workout this morning, felt strong and energized."),
        (4, 4, "Rough day, stressed about an upcoming deadline."),
        (3, 7, "Caught up with an old friend over coffee, really lifted my mood."),
        (2, 5, "Pretty average day, nothing special happened."),
        (1, 9, "Great weekend vibes, relaxed and spent time outdoors."),
    ]

    static func seed(context: ModelContext) {
        let calendar = Calendar.current
        for sample in entries {
            guard let date = calendar.date(byAdding: .day, value: -sample.daysAgo, to: Date()) else { continue }
            let entry = MoodEntry(date: date, moodScore: sample.score, summary: sample.summary)
            context.insert(entry)
        }
    }

    // MARK: - Full year seeding (for exercising Insights: week navigation,
    // the 12-month heatmap, streaks, and mood-band tallies)

    private static let summariesByBand: [String: [String]] = [
        "Crying": [
            "Everything felt like too much today, could barely get out of bed.",
            "Cried on and off most of the day, just felt overwhelmed.",
            "One of the hardest days I've had in a while.",
            "Felt completely drained and hopeless by the evening."
        ],
        "Sad": [
            "Been feeling pretty low, hard to shake it off.",
            "Missed some deadlines and it's weighing on me.",
            "Didn't really want to talk to anyone today.",
            "Felt lonely most of the afternoon.",
            "Rough day, stressed about an upcoming deadline."
        ],
        "Neutral": [
            "Pretty average day, nothing special happened.",
            "Kept busy with work, feeling pretty steady overall.",
            "Nothing much to report, just an ordinary day.",
            "Felt fine, neither great nor bad.",
            "Ran errands and caught up on chores."
        ],
        "Happy": [
            "Caught up with an old friend over coffee, really lifted my mood.",
            "Had a great workout this morning, felt strong and energized.",
            "Enjoyed a nice walk outside, weather was perfect.",
            "Got some good news at work today.",
            "Cooked a really good dinner and relaxed."
        ],
        "Joyful": [
            "Great weekend vibes, relaxed and spent time outdoors.",
            "Had an amazing time celebrating with family.",
            "Everything just clicked today, felt fantastic.",
            "Best day in weeks, full of laughter and good company.",
            "Accomplished a big goal I've been working toward."
        ]
    ]

    /// Deterministic xorshift64 generator so repeated seeding produces the
    /// same realistic-looking spread of data for testing.
    private struct SeededGenerator: RandomNumberGenerator {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed == 0 ? 0xDEAD_BEEF : seed
        }

        mutating func next() -> UInt64 {
            state ^= state << 13
            state ^= state >> 7
            state ^= state << 17
            return state
        }
    }

    /// Replaces all existing entries with ~a year of realistic, gappy
    /// mood data: seasonal drift, occasional multiple entries per day,
    /// ~18% of days skipped (except the last 10 days, which are always
    /// logged to guarantee a visible current streak).
    static func seedFullYear(context: ModelContext) {
        clearAllEntries(context: context)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var generator = SeededGenerator(seed: 42)

        for dayOffset in stride(from: 364, through: 0, by: -1) {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

            let forceLog = dayOffset <= 9
            if !forceLog && Double.random(in: 0...1, using: &generator) < 0.18 {
                continue
            }

            let seasonal = sin(Double(dayOffset) / 30.0) * 1.5
            let baseline = 6.3 + seasonal
            let noise = Double.random(in: -2.5...2.5, using: &generator)
            let dayScore = clampScore(Int((baseline + noise).rounded()))

            let entryCount = Double.random(in: 0...1, using: &generator) < 0.15 ? 2 : 1
            for entryIndex in 0..<entryCount {
                let hourRange = entryIndex == 0 ? 8...11 : 18...22
                let hour = Int.random(in: hourRange, using: &generator)
                let minute = Int.random(in: 0...59, using: &generator)
                guard let entryDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) else { continue }

                let jitter = Int.random(in: -1...1, using: &generator)
                let entryScore = clampScore(dayScore + jitter)
                let summary = randomSummary(for: entryScore, using: &generator)

                context.insert(MoodEntry(date: entryDate, moodScore: entryScore, summary: summary))
            }
        }
    }

    private static func clampScore(_ score: Int) -> Int {
        max(1, min(10, score))
    }

    private static func randomSummary(for score: Int, using generator: inout SeededGenerator) -> String {
        let band = MoodStyle.label(for: score)
        let pool = summariesByBand[band] ?? ["Logged a mood today."]
        let index = Int.random(in: 0..<pool.count, using: &generator)
        return pool[index]
    }

    private static func clearAllEntries(context: ModelContext) {
        let descriptor = FetchDescriptor<MoodEntry>()
        guard let existing = try? context.fetch(descriptor) else { return }
        for entry in existing {
            context.delete(entry)
        }
    }
}
#endif

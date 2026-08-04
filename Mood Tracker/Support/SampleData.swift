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
}
#endif

//
//  MoodEntry.swift
//  Mood Tracker
//

import Foundation
import SwiftData

@Model
final class MoodEntry {
    var date: Date
    var moodScore: Int
    var summary: String

    init(date: Date = Date(), moodScore: Int, summary: String) {
        self.date = date
        self.moodScore = moodScore
        self.summary = summary
    }

    var emoji: String {
        MoodStyle.emoji(for: moodScore)
    }
}

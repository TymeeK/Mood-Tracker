//
//  MoodEntryViewModel.swift
//  Mood Tracker
//

import SwiftUI
import SwiftData
import Observation

@Observable
final class MoodEntryViewModel {
    var moodScore: Int = 5
    var summary: String = ""
    var showSavedBanner = false

    var canSave: Bool {
        !summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func save(context: ModelContext, existingEntries: [MoodEntry], remindersEnabled: Bool, hour: Int, minute: Int) {
        let entry = MoodEntry(moodScore: moodScore, summary: summary.trimmingCharacters(in: .whitespacesAndNewlines))
        context.insert(entry)

        if remindersEnabled {
            NotificationScheduler.refreshSchedule(hour: hour, minute: minute, entries: existingEntries + [entry])
        }

        moodScore = 5
        summary = ""

        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            showSavedBanner = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            withAnimation(.easeOut(duration: 0.3)) {
                self?.showSavedBanner = false
            }
        }
    }
}

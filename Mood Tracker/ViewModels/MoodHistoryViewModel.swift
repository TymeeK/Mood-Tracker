//
//  MoodHistoryViewModel.swift
//  Mood Tracker
//

import SwiftData
import Observation

@Observable
final class MoodHistoryViewModel {
    enum ViewMode: String, CaseIterable {
        case list = "List"
        case calendar = "Calendar"
    }

    var viewMode: ViewMode = .list

    func delete(
        _ entry: MoodEntry,
        context: ModelContext,
        allEntries: [MoodEntry],
        remindersEnabled: Bool,
        hour: Int,
        minute: Int
    ) {
        context.delete(entry)

        if remindersEnabled {
            let remaining = allEntries.filter { $0 !== entry }
            NotificationScheduler.refreshSchedule(hour: hour, minute: minute, entries: remaining)
        }
    }
}

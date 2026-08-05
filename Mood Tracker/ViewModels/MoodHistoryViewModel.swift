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

    func delete(_ entry: MoodEntry, context: ModelContext) {
        context.delete(entry)
    }
}

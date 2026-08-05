//
//  NotificationsViewModelTests.swift
//  Mood TrackerTests
//

import Testing
import Foundation
@testable import Mood_Tracker

@MainActor
struct NotificationsViewModelTests {
    private let calendar = Calendar.current

    @Test func loadReminderTimeSetsHourAndMinuteOnToday() {
        let viewModel = NotificationsViewModel()

        viewModel.loadReminderTime(hour: 7, minute: 45)

        let components = calendar.dateComponents([.hour, .minute], from: viewModel.reminderTime)
        #expect(components.hour == 7)
        #expect(components.minute == 45)
        #expect(calendar.isDateInToday(viewModel.reminderTime))
    }

    @Test func componentsExtractsHourAndMinuteFromDate() {
        let viewModel = NotificationsViewModel()
        let date = calendar.date(bySettingHour: 22, minute: 30, second: 0, of: Date())!

        let result = viewModel.components(from: date)

        #expect(result.hour == 22)
        #expect(result.minute == 30)
    }
}

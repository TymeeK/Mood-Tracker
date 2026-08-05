//
//  NotificationScheduler.swift
//  Mood Tracker
//

import Foundation
import UserNotifications

enum NotificationScheduler {
    private static let identifierPrefix = "dailyMoodReminder-"
    private static let daysAhead = 7

    /// Schedules one reminder per upcoming day, skipping any day that already
    /// has a mood entry (including today, once it's been logged).
    static func refreshSchedule(hour: Int, minute: Int, entries: [MoodEntry]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let calendar = Calendar.current
        let loggedDays = Set(entries.map { calendar.startOfDay(for: $0.date) })
        let today = calendar.startOfDay(for: Date())

        for offset in 0..<daysAhead {
            guard let day = calendar.date(byAdding: .day, value: offset, to: today),
                  !loggedDays.contains(day),
                  let fireDate = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day),
                  fireDate > Date()
            else { continue }

            let content = UNMutableNotificationContent()
            content.title = "How are you feeling?"
            content.body = "Take a moment to log today's mood."
            content.sound = .default

            let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            let request = UNNotificationRequest(identifier: identifierPrefix + "\(offset)", content: content, trigger: trigger)
            center.add(request)
        }
    }

    static func cancel() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

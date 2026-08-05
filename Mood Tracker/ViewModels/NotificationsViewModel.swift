//
//  NotificationsViewModel.swift
//  Mood Tracker
//

import Foundation
import UserNotifications
import Observation

@Observable
final class NotificationsViewModel {
    var reminderTime = Date()
    var permissionDenied = false

    func loadReminderTime(hour: Int, minute: Int) {
        reminderTime = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }

    func components(from date: Date) -> (hour: Int, minute: Int) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0, components.minute ?? 0)
    }

    func enableReminders(hour: Int, minute: Int, entries: [MoodEntry], completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { [weak self] in
                self?.permissionDenied = !granted
                if granted {
                    NotificationScheduler.refreshSchedule(hour: hour, minute: minute, entries: entries)
                }
                completion(granted)
            }
        }
    }

    func refreshPermissionStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { [weak self] in
                let isDenied = settings.authorizationStatus == .denied
                self?.permissionDenied = isDenied
                completion(isDenied)
            }
        }
    }
}

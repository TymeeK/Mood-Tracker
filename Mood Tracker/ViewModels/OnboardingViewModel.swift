//
//  OnboardingViewModel.swift
//  Mood Tracker
//

import Foundation
import UserNotifications
import Observation

@Observable
final class OnboardingViewModel {
    enum Step: Int, CaseIterable, Hashable {
        case name, gender, notifications
    }

    var current: Step = .name
    var permissionDenied = false

    func advance() {
        guard let next = Step(rawValue: current.rawValue + 1) else { return }
        current = next
    }

    func back() {
        guard let previous = Step(rawValue: current.rawValue - 1) else { return }
        current = previous
    }

    func canContinue(firstName: String) -> Bool {
        switch current {
        case .name:
            return !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .gender, .notifications:
            return true
        }
    }

    func enableReminders(hour: Int, minute: Int, completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { [weak self] in
                self?.permissionDenied = !granted
                if granted {
                    NotificationScheduler.refreshSchedule(hour: hour, minute: minute, entries: [])
                }
                completion(granted)
            }
        }
    }
}

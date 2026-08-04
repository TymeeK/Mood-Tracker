//
//  NotificationsView.swift
//  Mood Tracker
//

import SwiftUI
import UserNotifications

struct NotificationsView: View {
    @AppStorage("remindersEnabled") private var remindersEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 20
    @AppStorage("reminderMinute") private var reminderMinute = 0

    @State private var reminderTime = Date()
    @State private var permissionDenied = false

    var body: some View {
        Form {
            Section {
                Toggle("Daily Reminder", isOn: $remindersEnabled)
                    .onChange(of: remindersEnabled) { _, isOn in
                        if isOn {
                            enableReminders()
                        } else {
                            NotificationScheduler.cancel()
                        }
                    }

                if remindersEnabled {
                    DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .onChange(of: reminderTime) { _, newValue in
                            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                            reminderHour = components.hour ?? reminderHour
                            reminderMinute = components.minute ?? reminderMinute
                            NotificationScheduler.schedule(hour: reminderHour, minute: reminderMinute)
                        }
                }
            } footer: {
                Text("We'll send a reminder to log your mood every day at this time.")
            }

            if permissionDenied {
                Section {
                    Text("Notifications are turned off for Mood Tracker in iOS Settings.")
                        .foregroundStyle(.secondary)
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            reminderTime = Calendar.current.date(bySettingHour: reminderHour, minute: reminderMinute, second: 0, of: Date()) ?? Date()
            refreshPermissionStatus()
        }
    }

    private func enableReminders() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                permissionDenied = !granted
                if granted {
                    NotificationScheduler.schedule(hour: reminderHour, minute: reminderMinute)
                } else {
                    remindersEnabled = false
                }
            }
        }
    }

    private func refreshPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .denied {
                    permissionDenied = true
                    remindersEnabled = false
                } else {
                    permissionDenied = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}

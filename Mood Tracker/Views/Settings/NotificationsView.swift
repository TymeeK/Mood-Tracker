//
//  NotificationsView.swift
//  Mood Tracker
//

import SwiftUI
import SwiftData
import UserNotifications

struct NotificationsView: View {
    @AppStorage("remindersEnabled") private var remindersEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 20
    @AppStorage("reminderMinute") private var reminderMinute = 0

    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    @State private var viewModel = NotificationsViewModel()

    var body: some View {
        Form {
            Section {
                Toggle("Daily Reminder", isOn: $remindersEnabled)
                    .onChange(of: remindersEnabled) { _, isOn in
                        if isOn {
                            viewModel.enableReminders(hour: reminderHour, minute: reminderMinute, entries: entries) { granted in
                                if !granted {
                                    remindersEnabled = false
                                }
                            }
                        } else {
                            NotificationScheduler.cancel()
                        }
                    }

                if remindersEnabled {
                    DatePicker("Time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                        .onChange(of: viewModel.reminderTime) { _, newValue in
                            let components = viewModel.components(from: newValue)
                            reminderHour = components.hour
                            reminderMinute = components.minute
                            NotificationScheduler.refreshSchedule(hour: reminderHour, minute: reminderMinute, entries: entries)
                        }
                }
            } footer: {
                Text("We'll send a reminder to log your mood every day at this time.")
            }

            if viewModel.permissionDenied {
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
            viewModel.loadReminderTime(hour: reminderHour, minute: reminderMinute)
            viewModel.refreshPermissionStatus { isDenied in
                if isDenied {
                    remindersEnabled = false
                }
            }
            if remindersEnabled {
                NotificationScheduler.refreshSchedule(hour: reminderHour, minute: reminderMinute, entries: entries)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}

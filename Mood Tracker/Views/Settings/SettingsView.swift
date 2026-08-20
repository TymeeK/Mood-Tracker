//
//  SettingsView.swift
//  Mood Tracker
//
//  Created by Tymee Kong on 8/2/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [MoodEntry]
    
    @State private var showDeleteConfirmation = false
    @State private var showExportSheet = false

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Label("Profile", systemImage: "person.circle")
                    }
                    NavigationLink {
                        NotificationsView()
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }
                }
                
                Section("Data") {
                    Button {
                        showExportSheet = true
                    } label: {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete All Data", systemImage: "trash")
                    }
                }
                
                Section("About") {
                    Link(destination: URL(string: "https://tymeek.github.io/Mood-Tracker/privacy.html")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    
                    Button {
                        if let url = URL(string: "mailto:tymeekong562@gmail.com") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Label("Support", systemImage: "questionmark.circle")
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                }

                #if DEBUG
                Section("Developer") {
                    Button {
                        SampleData.seed(context: modelContext)
                    } label: {
                        Label("Load Sample Data", systemImage: "wand.and.stars")
                    }
                    Button {
                        SampleData.seedFullYear(context: modelContext)
                    } label: {
                        Label("Load Full Year of Data", systemImage: "calendar.badge.clock")
                    }
                }
                #endif
            }
            .navigationTitle("Settings")
            .alert("Delete All Data?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This will permanently delete all your mood entries, profile information, and app settings. This action cannot be undone.")
            }
            .sheet(isPresented: $showExportSheet) {
                ExportDataView(entries: allEntries)
            }
        }
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    private func deleteAllData() {
        for entry in allEntries {
            modelContext.delete(entry)
        }
        
        UserDefaults.standard.removeObject(forKey: "profileFirstName")
        UserDefaults.standard.removeObject(forKey: "profileLastName")
        UserDefaults.standard.removeObject(forKey: "profileGender")
        UserDefaults.standard.removeObject(forKey: "remindersEnabled")
        UserDefaults.standard.removeObject(forKey: "reminderHour")
        UserDefaults.standard.removeObject(forKey: "reminderMinute")
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
    }
}

#Preview {
    SettingsView()
}

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
        }
    }
}

#Preview {
    SettingsView()
}

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
                    Label("Profile", systemImage: "person.circle")
                    Label("Notifications", systemImage: "bell")
                }

                Section("App") {
                    Label("Appearance", systemImage: "paintbrush")
                    Label("Privacy", systemImage: "lock.shield")
                }

                #if DEBUG
                Section("Developer") {
                    Button {
                        SampleData.seed(context: modelContext)
                    } label: {
                        Label("Load Sample Data", systemImage: "wand.and.stars")
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

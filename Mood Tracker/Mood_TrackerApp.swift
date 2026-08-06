//
//  Mood_TrackerApp.swift
//  Mood Tracker
//
//  Created by Tymee Kong on 8/2/26.
//

import SwiftUI
import SwiftData

@main
struct Mood_TrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MoodEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.light)
                .task {
                    #if DEBUG
                    if ProcessInfo.processInfo.environment["SEED_SAMPLE_DATA"] == "1" {
                        SampleData.seed(context: sharedModelContainer.mainContext)
                    }
                    #endif
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

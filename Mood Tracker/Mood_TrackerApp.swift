//
//  Mood_TrackerApp.swift
//  Mood Tracker
//
//  Created by Tymee Kong on 8/2/26.
//

import SwiftUI
import SwiftData
import os.log

/// Result of trying to stand up the app's `ModelContainer`, including how
/// degraded (if at all) the outcome is so the UI can inform the user.
private enum ModelContainerResult {
    case ready(ModelContainer, recoveryMessage: String?)
    case unrecoverable
}

@main
struct Mood_TrackerApp: App {
    @State private var containerResult: ModelContainerResult
    @State private var isShowingRecoveryAlert: Bool

    init() {
        let result = Self.makeContainerResult()
        _containerResult = State(initialValue: result)
        if case .ready(_, let message) = result {
            _isShowingRecoveryAlert = State(initialValue: message != nil)
        } else {
            _isShowingRecoveryAlert = State(initialValue: false)
        }
    }

    var body: some Scene {
        WindowGroup {
            switch containerResult {
            case .ready(let container, let recoveryMessage):
                MainTabView()
                    .preferredColorScheme(.light)
                    .task {
                        #if DEBUG
                        if ProcessInfo.processInfo.environment["SEED_SAMPLE_DATA"] == "1" {
                            SampleData.seed(context: container.mainContext)
                        }
                        if ProcessInfo.processInfo.environment["SEED_FULL_YEAR_DATA"] == "1" {
                            SampleData.seedFullYear(context: container.mainContext)
                        }
                        #endif
                    }
                    .alert("We had to reset your data", isPresented: $isShowingRecoveryAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(recoveryMessage ?? "")
                    }
                    .modelContainer(container)
            case .unrecoverable:
                DataErrorView {
                    containerResult = Self.makeContainerResult()
                    if case .ready(_, let message) = containerResult {
                        isShowingRecoveryAlert = message != nil
                    }
                }
            }
        }
    }

    // MARK: - Container setup

    private static let logger = Logger(subsystem: "MoodTracker", category: "ModelContainer")

    /// Tries to load the persistent store, then falls back to progressively
    /// safer options (reset store, in-memory) instead of crashing the app
    /// outright if the on-disk database can't be opened (e.g. corruption).
    private static func makeContainerResult() -> ModelContainerResult {
        let schema = Schema([MoodEntry.self])
        let persistentConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        if let container = try? ModelContainer(for: schema, configurations: [persistentConfiguration]) {
            return .ready(container, recoveryMessage: nil)
        }
        logger.error("Failed to load persistent ModelContainer; attempting to reset the local store.")

        deleteStoreFiles(at: persistentConfiguration.url)

        if let container = try? ModelContainer(for: schema, configurations: [persistentConfiguration]) {
            return .ready(
                container,
                recoveryMessage: "We ran into a problem loading your saved moods and had to reset your local data. We're sorry for the inconvenience."
            )
        }
        logger.error("Failed to load ModelContainer even after resetting the store; falling back to an in-memory session.")

        let inMemoryConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        if let container = try? ModelContainer(for: schema, configurations: [inMemoryConfiguration]) {
            return .ready(
                container,
                recoveryMessage: "Your mood history couldn't be loaded, so entries won't be saved after you close the app. Please restart Mood Tracker."
            )
        }
        logger.fault("Failed to create even an in-memory ModelContainer.")

        return .unrecoverable
    }

    /// Removes the SQLite store and its companion WAL/SHM files at the given
    /// location so a corrupted database doesn't keep failing to load.
    private static func deleteStoreFiles(at url: URL) {
        let fileManager = FileManager.default
        for suffix in ["", "-wal", "-shm"] {
            let fileURL = URL(fileURLWithPath: url.path + suffix)
            try? fileManager.removeItem(at: fileURL)
        }
    }
}

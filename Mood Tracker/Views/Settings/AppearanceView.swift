//
//  AppearanceView.swift
//  Mood Tracker
//

import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

struct AppearanceView: View {
    @AppStorage("appearanceMode") private var appearanceRaw: String = AppearanceMode.system.rawValue

    var body: some View {
        Form {
            Picker("Appearance", selection: $appearanceRaw) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode.rawValue)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AppearanceView()
    }
}

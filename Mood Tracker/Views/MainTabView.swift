//
//  MainTabView.swift
//  Mood Tracker
//
//  Created by Tymee Kong on 8/2/26.
//

import SwiftUI

struct MainTabView: View {
    enum Tab {
        case home, mood, history, settings
    }

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)

            ContentView()
                .tabItem {
                    Label("Mood", systemImage: "face.smiling")
                }
                .tag(Tab.mood)

            MoodHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(Tab.history)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
        .tint(MoodStyle.color(for: 8))
    }
}

#Preview {
    MainTabView()
}

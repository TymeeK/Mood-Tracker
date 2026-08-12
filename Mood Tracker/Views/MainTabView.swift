//
//  MainTabView.swift
//  Mood Tracker
//
//  Created by Tymee Kong on 8/2/26.
//

import SwiftUI

struct MainTabView: View {
    enum Tab {
        case home, mood, history, insights, settings
    }

    @State private var selectedTab: Tab = .home
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)

            MoodEntryView()
                .tabItem {
                    Label("Mood", systemImage: "face.smiling")
                }
                .tag(Tab.mood)

            MoodHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(Tab.history)

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.xyaxis.line")
                }
                .tag(Tab.insights)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
        .tint(MoodStyle.color(for: 8))
        .fullScreenCover(isPresented: .init(
            get: { !hasCompletedOnboarding },
            set: { hasCompletedOnboarding = !$0 }
        )) {
            OnboardingView()
        }
    }
}

#Preview {
    MainTabView()
}

//
//  MoodStyle.swift
//  Mood Tracker
//

import SwiftUI

enum MoodStyle {
    static func emoji(for score: Int) -> String {
        switch score {
        case 1...2: return "😭"
        case 3...4: return "😞"
        case 5...6: return "😐"
        case 7...8: return "🙂"
        default: return "😄"
        }
    }

    static func color(for score: Int) -> Color {
        switch score {
        case 1...2: return Color(red: 0.42, green: 0.45, blue: 0.68)
        case 3...4: return Color(red: 0.35, green: 0.58, blue: 0.72)
        case 5...6: return Color(red: 0.93, green: 0.69, blue: 0.35)
        case 7...8: return Color(red: 0.95, green: 0.55, blue: 0.45)
        default: return Color(red: 0.87, green: 0.38, blue: 0.62)
        }
    }

    static func secondaryColor(for score: Int) -> Color {
        switch score {
        case 1...2: return Color(red: 0.29, green: 0.31, blue: 0.53)
        case 3...4: return Color(red: 0.24, green: 0.42, blue: 0.58)
        case 5...6: return Color(red: 0.97, green: 0.82, blue: 0.5)
        case 7...8: return Color(red: 0.98, green: 0.72, blue: 0.42)
        default: return Color(red: 0.62, green: 0.36, blue: 0.78)
        }
    }

    static func gradient(for score: Int) -> LinearGradient {
        LinearGradient(
            colors: [color(for: score), secondaryColor(for: score)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func backgroundGradient(for score: Int) -> LinearGradient {
        LinearGradient(
            colors: [
                color(for: score).opacity(0.35),
                secondaryColor(for: score).opacity(0.18),
                Color(.systemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case ..<12: return "Good morning"
        case 12..<18: return "Good afternoon"
        default: return "Good evening"
        }
    }
}

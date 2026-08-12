//
//  MoodIconView.swift
//  Mood Tracker
//

import SwiftUI

struct MoodIconView: View {
    let score: Int
    var size: CGFloat = 34

    var body: some View {
        Image(MoodStyle.iconName(for: score))
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .accessibilityLabel(Text("Mood \(score) out of 10"))
    }
}

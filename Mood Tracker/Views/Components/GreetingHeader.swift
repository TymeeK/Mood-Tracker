//
//  GreetingHeader.swift
//  Mood Tracker
//

import SwiftUI

struct GreetingHeader: View {
    @AppStorage("profileFirstName") private var firstName: String = ""

    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(MoodStyle.greeting(name: firstName))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title2.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    GreetingHeader(title: "How is your mood today?")
        .padding()
}

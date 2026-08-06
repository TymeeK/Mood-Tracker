//
//  OnboardingNameStepView.swift
//  Mood Tracker
//

import SwiftUI

struct OnboardingNameStepView: View {
    @Binding var firstName: String
    @Binding var lastName: String

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            OnboardingStepHeader(
                icon: "person.fill",
                title: "Welcome to Mood Tracker",
                subtitle: "Let's start with your name."
            )

            VStack(spacing: 12) {
                OnboardingMaterialTextField(placeholder: "First name", text: $firstName)
                OnboardingMaterialTextField(placeholder: "Last name (optional)", text: $lastName)
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    ZStack {
        MoodStyle.backgroundGradient(for: 8).ignoresSafeArea()
        OnboardingNameStepView(firstName: .constant(""), lastName: .constant(""))
    }
}

//
//  OnboardingNotificationsStepView.swift
//  Mood Tracker
//

import SwiftUI

struct OnboardingNotificationsStepView: View {
    let isEnabling: Bool
    let onEnable: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            OnboardingStepHeader(
                icon: "bell.badge.fill",
                title: "Stay on track",
                subtitle: "We'll send a daily reminder so you never miss logging your mood."
            )

            VStack(spacing: 14) {
                OnboardingPrimaryButton(title: "Enable Notifications", isDisabled: isEnabling, action: onEnable)

                Button("Maybe Later", action: onSkip)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
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
        OnboardingNotificationsStepView(isEnabling: false, onEnable: {}, onSkip: {})
    }
}

//
//  OnboardingComponents.swift
//  Mood Tracker
//

import SwiftUI

private let onboardingAccentScore = 8

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? AnyShapeStyle(MoodStyle.gradient(for: onboardingAccentScore)) : AnyShapeStyle(.thinMaterial))
                    .frame(height: 6)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }
}

struct OnboardingStepHeader: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(Circle().fill(MoodStyle.gradient(for: onboardingAccentScore)))
                .shadow(color: MoodStyle.color(for: onboardingAccentScore).opacity(0.3), radius: 14, y: 6)

            VStack(spacing: 6) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 32)
    }
}

struct OnboardingMaterialTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.thinMaterial)
            )
    }
}

struct OnboardingPrimaryButton: View {
    let title: String
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Capsule().fill(MoodStyle.gradient(for: onboardingAccentScore)))
        }
        .opacity(isDisabled ? 0.4 : 1)
        .disabled(isDisabled)
    }
}

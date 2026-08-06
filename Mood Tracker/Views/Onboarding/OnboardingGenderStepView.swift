//
//  OnboardingGenderStepView.swift
//  Mood Tracker
//

import SwiftUI

struct OnboardingGenderStepView: View {
    @Binding var genderRaw: String

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            OnboardingStepHeader(
                icon: "person.crop.circle",
                title: "How do you identify?",
                subtitle: "You can change this later in Settings."
            )

            VStack(spacing: 10) {
                ForEach(Gender.allCases) { gender in
                    genderOption(gender)
                }
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }

    private func genderOption(_ gender: Gender) -> some View {
        let isSelected = gender.rawValue == genderRaw
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                genderRaw = gender.rawValue
            }
        } label: {
            HStack {
                Text(gender.rawValue)
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : .primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(MoodStyle.gradient(for: 8)) : AnyShapeStyle(.thinMaterial))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        MoodStyle.backgroundGradient(for: 8).ignoresSafeArea()
        OnboardingGenderStepView(genderRaw: .constant(Gender.preferNotToSay.rawValue))
    }
}

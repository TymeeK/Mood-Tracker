//
//  OnboardingView.swift
//  Mood Tracker
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("profileFirstName") private var firstName: String = ""
    @AppStorage("profileLastName") private var lastName: String = ""
    @AppStorage("profileGender") private var genderRaw: String = Gender.preferNotToSay.rawValue

    @AppStorage("remindersEnabled") private var remindersEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 20
    @AppStorage("reminderMinute") private var reminderMinute = 0

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var viewModel = OnboardingViewModel()
    @State private var isEnablingNotifications = false

    var body: some View {
        ZStack {
            MoodStyle.backgroundGradient(for: 8)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                OnboardingProgressBar(
                    currentStep: viewModel.current.rawValue,
                    totalSteps: OnboardingViewModel.Step.allCases.count
                )
                .padding(.horizontal, 32)
                .padding(.top, 16)

                Group {
                    switch viewModel.current {
                    case .name:
                        OnboardingNameStepView(firstName: $firstName, lastName: $lastName)
                    case .gender:
                        OnboardingGenderStepView(genderRaw: $genderRaw)
                    case .notifications:
                        OnboardingNotificationsStepView(
                            isEnabling: isEnablingNotifications,
                            onEnable: enableNotifications,
                            onSkip: finish
                        )
                    }
                }
                .id(viewModel.current)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
                .frame(maxHeight: .infinity)

                if viewModel.current != .notifications {
                    navigationBar
                }
            }
        }
    }

    private var navigationBar: some View {
        HStack {
            if viewModel.current != .name {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { viewModel.back() }
                } label: {
                    Text("Back")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.25)) { viewModel.advance() }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(MoodStyle.gradient(for: 8)))
            }
            .opacity(viewModel.canContinue(firstName: firstName) ? 1 : 0.4)
            .disabled(!viewModel.canContinue(firstName: firstName))
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 24)
    }

    private func enableNotifications() {
        isEnablingNotifications = true
        viewModel.enableReminders(hour: reminderHour, minute: reminderMinute) { granted in
            isEnablingNotifications = false
            remindersEnabled = granted
            finish()
        }
    }

    private func finish() {
        hasCompletedOnboarding = true
    }
}

#Preview {
    OnboardingView()
}

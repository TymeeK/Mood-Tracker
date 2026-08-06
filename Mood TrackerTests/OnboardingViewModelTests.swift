//
//  OnboardingViewModelTests.swift
//  Mood TrackerTests
//

import Testing
import Foundation
@testable import Mood_Tracker

@MainActor
struct OnboardingViewModelTests {
    @Test func advanceMovesThroughStepsInOrder() {
        let viewModel = OnboardingViewModel()

        #expect(viewModel.current == .name)
        viewModel.advance()
        #expect(viewModel.current == .gender)
        viewModel.advance()
        #expect(viewModel.current == .notifications)
    }

    @Test func advanceClampsAtLastStep() {
        let viewModel = OnboardingViewModel()
        viewModel.advance()
        viewModel.advance()
        viewModel.advance()

        #expect(viewModel.current == .notifications)
    }

    @Test func backMovesToPreviousStep() {
        let viewModel = OnboardingViewModel()
        viewModel.advance()

        viewModel.back()

        #expect(viewModel.current == .name)
    }

    @Test func backClampsAtFirstStep() {
        let viewModel = OnboardingViewModel()

        viewModel.back()

        #expect(viewModel.current == .name)
    }

    @Test func canContinueRequiresNonEmptyFirstNameOnNameStep() {
        let viewModel = OnboardingViewModel()

        #expect(viewModel.canContinue(firstName: "") == false)
        #expect(viewModel.canContinue(firstName: "   ") == false)
        #expect(viewModel.canContinue(firstName: "Tymee") == true)
    }

    @Test func canContinueAlwaysTrueOnLaterSteps() {
        let viewModel = OnboardingViewModel()
        viewModel.advance()

        #expect(viewModel.canContinue(firstName: "") == true)
    }
}

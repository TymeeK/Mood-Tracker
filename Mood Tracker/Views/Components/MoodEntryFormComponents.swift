//
//  MoodEntryFormComponents.swift
//  Mood Tracker
//

import SwiftUI

struct MoodHeroCard: View {
    let moodScore: Int

    var body: some View {
        VStack(spacing: 8) {
            Text(MoodStyle.emoji(for: moodScore))
                .font(.system(size: 72))
                .id(moodScore)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(response: 0.35, dampingFraction: 0.6), value: moodScore)

            Text("\(moodScore) / 10")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.regularMaterial)
        )
        .shadow(color: MoodStyle.color(for: moodScore).opacity(0.25), radius: 16, y: 8)
    }
}

struct MoodScorePicker: View {
    @Binding var moodScore: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...10, id: \.self) { score in
                let isSelected = score == moodScore
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        moodScore = score
                    }
                } label: {
                    Text("\(score)")
                        .font(.caption.weight(isSelected ? .bold : .medium))
                        .foregroundStyle(isSelected ? .white : .primary)
                        .frame(width: isSelected ? 30 : 24, height: isSelected ? 30 : 24)
                        .background(
                            Circle()
                                .fill(isSelected ? AnyShapeStyle(MoodStyle.gradient(for: score)) : AnyShapeStyle(.thinMaterial))
                        )
                        .overlay(
                            Circle()
                                .strokeBorder(isSelected ? MoodStyle.color(for: score) : .clear, lineWidth: 2)
                                .padding(-2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.thinMaterial)
        )
    }
}

struct MoodSummaryEditor: View {
    @Binding var summary: String
    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What's on your mind?")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            ZStack(alignment: .topLeading) {
                if summary.isEmpty {
                    Text("Write a little about what happened today…")
                        .foregroundStyle(.tertiary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
                TextEditor(text: $summary)
                    .scrollContentBackground(.hidden)
                    .frame(height: 130)
                    .focused(isFocused)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.thinMaterial)
        )
    }
}

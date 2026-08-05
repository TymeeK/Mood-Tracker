//
//  MoodEntryView.swift
//  Mood Tracker
//
//  Created by Tymee Kong on 8/2/26.
//

import SwiftUI
import SwiftData

struct MoodEntryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \MoodEntry.date, order: .reverse) private var entries: [MoodEntry]

    @AppStorage("remindersEnabled") private var remindersEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 20
    @AppStorage("reminderMinute") private var reminderMinute = 0

    @State private var moodScore: Int = 5
    @State private var summary: String = ""
    @State private var showSavedBanner = false

    var body: some View {
        NavigationStack {
            ZStack {
                MoodStyle.backgroundGradient(for: moodScore)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.4), value: moodScore)

                ScrollView {
                    VStack(spacing: 24) {
                        header

                        heroCard

                        moodPicker

                        summaryCard

                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                }

                if showSavedBanner {
                    savedBanner
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        GreetingHeader(title: "How are you feeling?")
    }

    private var heroCard: some View {
        VStack(spacing: 8) {
            Text(MoodStyle.emoji(for: moodScore))
                .font(.system(size: 72))
                .scaleEffect(1.0)
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

    private var moodPicker: some View {
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

    private var summaryCard: some View {
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
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.thinMaterial)
        )
    }

    private var saveButton: some View {
        Button {
            saveEntry()
        } label: {
            Text("Save")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(MoodStyle.gradient(for: moodScore))
                )
        }
        .opacity(summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1)
        .disabled(summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    private var savedBanner: some View {
        VStack {
            Spacer()
            Label("Saved", systemImage: "checkmark.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Capsule().fill(Color.primary.opacity(0.85)))
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func saveEntry() {
        let entry = MoodEntry(moodScore: moodScore, summary: summary.trimmingCharacters(in: .whitespacesAndNewlines))
        modelContext.insert(entry)

        if remindersEnabled {
            NotificationScheduler.refreshSchedule(hour: reminderHour, minute: reminderMinute, entries: entries + [entry])
        }

        moodScore = 5
        summary = ""

        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            showSavedBanner = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                showSavedBanner = false
            }
        }
    }
}

#Preview {
    MoodEntryView()
        .modelContainer(for: MoodEntry.self, inMemory: true)
}

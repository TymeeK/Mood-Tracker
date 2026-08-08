//
//  DataErrorView.swift
//  Mood Tracker
//
//  Shown instead of crashing when the app's local database can't be
//  loaded at all, even after attempting to reset it.
//

import SwiftUI

struct DataErrorView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Something Went Wrong")
                .font(.title2.weight(.semibold))

            Text("Mood Tracker couldn't load its local data. Try again, and if the problem continues, try reinstalling the app.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: onRetry) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.accentColor))
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    DataErrorView(onRetry: {})
}

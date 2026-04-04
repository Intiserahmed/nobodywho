//
//  LoadingView.swift
//  NobodyWatch Watch App
//

import SwiftUI

struct LoadingView: View {
    var hasError: Bool
    var errorMessage: String
    var onRetry: () -> Void

    var body: some View {
        if hasError {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundStyle(.red)

                Text(errorMessage)
                    .font(.caption2)
                    .multilineTextAlignment(.center)

                Button {
                    onRetry()
                } label: {
                    Label("Retry", systemImage: "arrow.clockwise")
                }
            }
        } else {
            VStack(spacing: 8) {
                ProgressView()

                Text("Loading…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .onAppear {
                onRetry()
            }
        }
    }
}

#Preview("Loading") {
    LoadingView(hasError: false, errorMessage: "") {}
}

#Preview("Error") {
    LoadingView(hasError: true, errorMessage: "Failed to load model. Please try again.") {}
}

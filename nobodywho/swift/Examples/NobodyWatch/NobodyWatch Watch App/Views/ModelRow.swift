//
//  ModelRow.swift
//  NobodyWatch Watch App
//
//  Created by pierre on 22/03/2026.
//

import SwiftUI

struct ModelRow: View {
    let name: String
    let author: String
    let modelSizeMB: Int
    var showDownloadIcon: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            if showDownloadIcon {
                Image(systemName: "arrow.down.circle")
                    .font(.title3)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    Text(author)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(modelSizeMB) MB")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview("ModelRow") {
    List {
        ModelRow(name: "LFM2 350M Q2 K", author: "Liquid AI", modelSizeMB: 160)
        ModelRow(name: "LFM2 350M Q2 K", author: "Liquid AI", modelSizeMB: 160, showDownloadIcon: true)
    }
    .listStyle(.plain)
}

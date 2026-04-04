//
//  DownloadModelsView.swift
//  NobodyWatch Watch App
//

import SwiftUI

struct DownloadModelsView: View {
    private let endpoint = URL(string: "https://gist.githubusercontent.com/PierreBresson/f3da1a01c39417237fa2883fb11fe376/raw/6859398979565e0e474bd1858b0cc066cb7364fd/nobody-watchos-app.json")!

    @State private var remoteModels: [RemoteModel] = []
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    var body: some View {
        Group {
            if isLoading || errorMessage != nil {
                LoadingView(
                    hasError: errorMessage != nil,
                    errorMessage: errorMessage ?? "",
                    onRetry: fetchModels
                )
            } else if remoteModels.isEmpty {
                Text("There are no models to download.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                List {
                    ForEach(remoteModels) { model in
                        NavigationLink(destination: MainView()) {
                            ModelRow(name: model.name, author: model.author, modelSizeMB: model.sizeMB, showDownloadIcon: true)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Download")
        .onAppear {
            fetchModels()
        }
    }

    private func fetchModels() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: endpoint)
                let decoded = try JSONDecoder().decode([RemoteModel].self, from: data)
                await MainActor.run {
                    remoteModels = decoded
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Models could not be loaded. Try again later."
                    isLoading = false
                }
            }
        }
    }
}

#Preview("DownloadModelsView") {
    DownloadModelsView()
}

//
//  HomeView.swift
//  NobodyWatch Watch App
//

import SwiftUI

struct HomeView: View {
    private let endpoint = URL(string: "https://gist.githubusercontent.com/PierreBresson/f3da1a01c39417237fa2883fb11fe376/raw/6859398979565e0e474bd1858b0cc066cb7364fd/nobody-watchos-app.json")!

    @State private var remoteModels: [RemoteModel] = []
    @State private var errorMessage: String? = nil

    var body: some View {
        Group {
            if remoteModels.isEmpty {
                Text("No remote models available.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                List {
                    Section(header: Text("Downloaded").padding(.bottom, 8)) {
                        ForEach(remoteModels) { model in
                            NavigationLink(destination: MainView()) {
                                ModelRow(name: model.name, author: model.author, modelSizeMB: model.sizeMB)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Models")
    }
}

#Preview("HomeView") {
    NavigationStack {
        HomeView()
    }
}

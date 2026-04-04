//
//  MainView.swift
//  NobodyWatch Watch App
//
//  Created by pierre on 20/03/2026.
//

import SwiftUI

struct MainView: View {
    @State private var session = ChatSession()

    var body: some View {
        if session.modelLoaded {
            ChatView(session: session)
        } else {
            LoadingView(hasError: session.errorLoadingModel, errorMessage: "Failed to load model. Please try again.") {
                session.loadModel()
            }
        }
    }
}

#Preview {
    MainView()
}

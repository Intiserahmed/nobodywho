//
//  ContentView.swift
//  NobodyVision
//
//  Created by pierre on 27/03/2026.
//

import SwiftUI
import NobodyWho

struct ContentView: View {
    @State private var session = ChatSession()

    var body: some View {
        VStack(spacing: 16) {
            if !session.modelLoaded {
                // Loading state
                VStack(spacing: 12) {
                    if session.errorLoadingModel {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.red)
                        Text("Failed to load model")
                            .font(.title3)
                        Button("Retry") {
                            session.loadModel()
                        }
                    } else {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading model...")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(session.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            if session.isLoading {
                                HStack {
                                    ProgressView()
                                    Text("Thinking...")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.leading)
                                .id("loading")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: session.messages.count) {
                        if let last = session.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                // Input bar
                HStack {
                    TextField("Ask something...", text: $session.inputText)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            session.sendMessage()
                        }

                    Button {
                        session.sendMessage()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .disabled(session.inputText.isEmpty || session.isLoading)
                }
                .padding()
            }
        }
        .frame(minWidth: 400, minHeight: 500)
        .onAppear {
            session.loadModel()
        }
    }
}

struct MessageBubble: View {
    let message: Message

    var isUser: Bool {
        message.role == .user
    }

    var body: some View {
        HStack {
            if isUser { Spacer() }

            Text(message.content)
                .padding(12)
                .background(isUser ? Color.blue : Color.gray.opacity(0.3))
                .foregroundStyle(isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            if !isUser { Spacer() }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}

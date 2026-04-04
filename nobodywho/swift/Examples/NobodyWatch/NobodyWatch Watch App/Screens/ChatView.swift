//
//  ChatView.swift
//  NobodyWatch Watch App
//

import SwiftUI

struct ChatView: View {
    @Bindable var session: ChatSession

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                List {
                    ForEach(session.messages) { message in
                        MessageBubble(message: message)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.bottom, message.id == session.messages.last?.id ? 8 : 0)
                            .id(message.id)
                    }
                    if session.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.7)
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .id("loading")
                    }
                    if let errorMessage = session.errorMessage {
                        Text(errorMessage)
                            .font(.caption2)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .onChange(of: session.messages.count) {
                    withAnimation {
                        proxy.scrollTo(session.messages.last?.id, anchor: .bottom)
                    }
                }
                .onChange(of: session.isLoading) {
                    if session.isLoading {
                        withAnimation {
                            proxy.scrollTo("loading", anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 4) {
                TextField("Ask something…", text: $session.inputText)
                    .font(.caption)
                Button {
                    session.sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(session.inputText.isEmpty || session.isLoading ? .gray : .blue)
                }
                .disabled(session.inputText.isEmpty || session.isLoading)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    let session = ChatSession()
    session.messages = [
        Message(role: .user, content: "What's the weather like?"),
        Message(role: .assistant, content: "I don't have access to live weather data, but you can check the Weather app on your watch."),
        Message(role: .user, content: "Thanks!"),
    ]
    return ChatView(session: session)
}

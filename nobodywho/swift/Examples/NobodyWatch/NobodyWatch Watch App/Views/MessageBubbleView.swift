//
//  MessageBubble.swift
//  NobodyWatch Watch App
//
//  Created by pierre on 20/03/2026.
//

import SwiftUI

struct MessageBubble: View {
    let message: Message

    var body: some View {
        Text(message.content)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(message.role == .user ? Color.blue : Color.gray.opacity(0.3))
            .foregroundStyle(message.role == .user ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
            .padding(.horizontal, 8)
    }
}

#Preview {
    VStack(spacing: 6) {
        MessageBubble(message: Message(role: .user, content: "Hello!"))
        MessageBubble(message: Message(role: .assistant, content: "Hi, how can I help?"))
    }
}

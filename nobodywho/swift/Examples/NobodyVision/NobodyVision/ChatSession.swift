//
//  ChatSession.swift
//  NobodyVision
//

import SwiftUI
import NobodyWho

struct Message: Identifiable {
    let id = UUID()
    let role: NobodyWho.Role
    let content: String
}

@Observable class ChatSession {
    var messages: [Message] = []
    var inputText: String = ""
    var isLoading: Bool = false
    var errorLoadingModel: Bool = false
    var modelLoaded: Bool = false
    var chat: Chat?

    private var modelPath: String {
        Bundle.main.path(forResource: "model", ofType: "gguf")!
    }

    func loadModel() {
        isLoading = true
        errorLoadingModel = false

        let path = modelPath
        Task.detached {
            do {
                initLogging()
                #if targetEnvironment(simulator)
                let useGpu = false
                #else
                let useGpu = true
                #endif
                let model = try NobodyWho.loadModel(path: path, useGpu: useGpu)
                let config = ChatConfig(
                    contextSize: 2048,
                    systemPrompt: "You are a helpful assistant running on Apple Vision Pro. Keep answers concise."
                )
                let chatInstance = try Chat(model: model, config: config)

                await MainActor.run {
                    self.chat = chatInstance
                    self.modelLoaded = true
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorLoadingModel = true
                    self.isLoading = false
                }
            }
        }
    }

    func sendMessage() {
        guard let chat, !inputText.isEmpty else { return }
        let question = inputText
        inputText = ""
        isLoading = true

        messages.append(Message(role: .user, content: question))

        Task.detached {
            do {
                let answer = try chat.askBlocking(prompt: question)

                await MainActor.run {
                    self.messages.append(Message(role: .assistant, content: answer))
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.messages.append(Message(role: .assistant, content: "Error: \(error.localizedDescription)"))
                    self.isLoading = false
                }
            }
        }
    }
}

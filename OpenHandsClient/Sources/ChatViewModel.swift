import Foundation
import Combine

struct Message: Identifiable, Codable {
    let id: UUID
    let role: String // "user" or "assistant"
    let content: String
    let timestamp: Date
}

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = [
        Message(id: UUID(), role: "assistant", content: "Welcome to OpenHands. Connected and ready.", timestamp: Date())
    ]
    @Published var inputText: String = ""
    @Published var serverURL: String = "http://localhost:3000"
    @Published var isConnected: Bool = false
    @Published var isLoading: Bool = false

    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let userMsg = Message(id: UUID(), role: "user", content: trimmed, timestamp: Date())
        messages.append(userMsg)
        inputText = ""
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let replyContent = "Received your message: \"\(userMsg.content)\". OpenHands agent is processing your request."
            let botMsg = Message(id: UUID(), role: "assistant", content: replyContent, timestamp: Date())
            self.messages.append(botMsg)
            self.isLoading = false
        }
    }
}

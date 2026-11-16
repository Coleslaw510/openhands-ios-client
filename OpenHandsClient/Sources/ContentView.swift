import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message)
                                }
                                if viewModel.isLoading {
                                    HStack(spacing: 8) {
                                        ProgressView()
                                            .tint(.white)
                                        Text("OpenHands is thinking...")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            if let last = viewModel.messages.last {
                                withAnimation {
                                    proxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }

                    Divider()
                        .background(Color(white: 0.2))

                    HStack(spacing: 12) {
                        TextField("Message OpenHands...", text: $viewModel.inputText, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(white: 0.1))
                            .cornerRadius(20)
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .lineLimit(1...5)

                        Button(action: {
                            viewModel.sendMessage()
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.white)
                        }
                        .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(12)
                    .background(Color.black)
                }
            }
            .navigationTitle("OpenHands")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message

    var isUser: Bool {
        message.role == "user"
    }

    var body: some View {
        HStack {
            if isUser { Spacer() }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(isUser ? Color(white: 0.2) : Color(white: 0.1))
                    .cornerRadius(16)

                Text(message.timestamp, style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(Color.gray)
                    .padding(.horizontal, 4)
            }
            .id(message.id)

            if !isUser { Spacer() }
        }
        .padding(.horizontal, 16)
    }
}

struct SettingsView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Connection")) {
                    TextField("Server URL", text: $viewModel.serverURL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                Section(header: Text("About")) {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0 (Unsigned IPA)")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("UI Style")
                        Spacer()
                        Text("Grok Dark Minimalist")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

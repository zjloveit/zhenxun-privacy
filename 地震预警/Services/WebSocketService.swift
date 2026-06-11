import Foundation

@MainActor
final class WebSocketService: NSObject, ObservableObject {
    @Published private(set) var isConnected = false
    @Published private(set) var lastError: String?

    var onEarlyWarning: ((EarlyWarning) -> Void)?

    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var shouldReconnect = false

    func connect() {
        shouldReconnect = true
        openConnection()
    }

    func disconnect() {
        shouldReconnect = false
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        session?.invalidateAndCancel()
        session = nil
        isConnected = false
    }

    private func openConnection() {
        disconnect()

        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        self.session = session

        let task = session.webSocketTask(with: WolfxEndpoints.jmaEEWWebSocket)
        webSocketTask = task
        task.resume()
        listen()
        sendPing()
    }

    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let message):
                Task { @MainActor in
                    self.isConnected = true
                    self.lastError = nil
                }

                switch message {
                case .string(let text):
                    self.handle(text: text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handle(text: text)
                    }
                @unknown default:
                    break
                }

                self.listen()

            case .failure(let error):
                Task { @MainActor in
                    self.isConnected = false
                    self.lastError = error.localizedDescription
                    if self.shouldReconnect {
                        try? await Task.sleep(for: .seconds(5))
                        self.openConnection()
                    }
                }
            }
        }
    }

    private func handle(text: String) {
        guard
            let data = text.data(using: .utf8),
            let payload = try? JSONDecoder().decode(WolfxJMAEEWResponse.self, from: data),
            let warning = payload.toEarlyWarning()
        else { return }

        Task { @MainActor in
            onEarlyWarning?(warning)
        }
    }

    private func sendPing() {
        webSocketTask?.sendPing { [weak self] error in
            guard let self else { return }
            if error != nil {
                Task { @MainActor in
                    self.isConnected = false
                }
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + 30) {
                guard self.shouldReconnect else { return }
                self.sendPing()
            }
        }
    }
}

extension WebSocketService: URLSessionWebSocketDelegate {
    nonisolated func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        Task { @MainActor in
            isConnected = true
        }
    }

    nonisolated func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        Task { @MainActor in
            isConnected = false
        }
    }
}

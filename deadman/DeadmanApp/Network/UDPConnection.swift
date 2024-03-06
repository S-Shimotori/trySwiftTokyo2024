//
//  UDPConnection.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/03.
//

import Combine
import Foundation

protocol UDPConnectionProtocol {
    /// A publisher that publishes received messages.
    var receivedMessagePublisher: AnyPublisher<IPMessage, any Error> { get }

    /// Sends a message to a given address.
    /// - Parameters:
    ///   - message: Data to send.
    ///   - address: An internet address for destination.
    /// - Throws: `POSIXError`
    func send(message: Data, to address: String) throws

    func beginPollingMessages()

    func stopPollingMessages()
}

// MARK: - UDPConnection

class UDPConnection {
    /// - ToDo: Inject a socket
    private let fileDescriptor: FileDescriptor
    private let dateProvider: any DateProviderProtocol

    private let receivedMessageSubject = PassthroughSubject<IPMessage, Error>()
    private var pollingTask: Task<Void, any Error>?

    init(fileDescriptor: consuming FileDescriptor, dateProvider: some DateProviderProtocol) {
        self.fileDescriptor = fileDescriptor
        self.dateProvider = dateProvider
    }
}

// MARK: extension (UDPConnectionProtocol)

extension UDPConnection: UDPConnectionProtocol {
    var receivedMessagePublisher: AnyPublisher<IPMessage, any Error> {
        receivedMessageSubject.eraseToAnyPublisher()
    }

    func beginPollingMessages() {
        guard pollingTask?.isCancelled != false else { return }
        pollingTask = Task {
            while true {
                do {
                    try await fileDescriptor.poll()
                    let receivedDate = dateProvider.now
                    let rawMessage = try fileDescriptor.recvfrom()
                    try receivedMessageSubject.send(.init(data: rawMessage.rawData, receivedDate: receivedDate))
                }
                catch {
                    // TODO: Handle errors on socket
                    receivedMessageSubject.send(completion: .failure(error))
                }
            }
        }
    }

    func stopPollingMessages() {
        pollingTask?.cancel()
    }

    func send(message: Data, to address: String) throws {
        let ipv4Address = inet_addr(address)
        guard ipv4Address != INADDR_NONE else {
            fatalError("TODO: handle invalid address error")
        }

        let internetAddress = sockaddr_in(
            sin_len: __uint8_t(MemoryLayout<sockaddr_in>.size),
            sin_family: sa_family_t(AF_INET),
            sin_port: 0,
            sin_addr: in_addr(s_addr: ipv4Address),
            sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
        )
        try fileDescriptor.send(message: message, to: internetAddress)
    }
}

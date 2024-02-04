//
//  UDPConnection.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/03.
//

import Combine
import Foundation

protocol UDPConnectionProtocol {
    var receivedMessagePublisher: AnyPublisher<Data, any Error> { get }

    func send(message: Data, to: String) throws
}

// MARK: - UDPConnection

class UDPConnection {
    private let fileDescriptor: FileDescriptor
    private let receivedMessageSubject = PassthroughSubject<Data, Error>()

    init(fileDescriptor: consuming FileDescriptor) {
        self.fileDescriptor = fileDescriptor
    }
}

// MARK: extension (UDPConnectionProtocol)

extension UDPConnection: UDPConnectionProtocol {
    var receivedMessagePublisher: AnyPublisher<Data, any Error> {
        receivedMessageSubject.eraseToAnyPublisher()
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

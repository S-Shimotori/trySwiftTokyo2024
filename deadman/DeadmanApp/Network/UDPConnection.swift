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

    func send(message: Data, to: String) throws {
        fatalError("TODO: implement ``UDPConnection/send(message:to:)``")
    }
}

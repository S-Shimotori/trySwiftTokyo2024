//
//  ICMPEchoRepository.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/03.
//

import Combine

protocol ICMPEchoRepositoryProtocol {
    var resultPublisher: AnyPublisher<ICMPEchoResult, any Error> { get }

    func sendRequest(identifier: UInt16, sequence: UInt16, to address: String)
}

// MARK: - ICMPEchoRepository

class ICMPEchoRepository {
    private let udpConnection: any UDPConnectionProtocol
    private let resultSubject = PassthroughSubject<ICMPEchoResult, Error>()

    init(udpConnection: some UDPConnectionProtocol) {
        self.udpConnection = udpConnection
    }
}

// MARK: extension (ICMPEchoRepositoryProtocol)

extension ICMPEchoRepository: ICMPEchoRepositoryProtocol {
    var resultPublisher: AnyPublisher<ICMPEchoResult, Error> {
        resultSubject.eraseToAnyPublisher()
    }

    func sendRequest(identifier: UInt16, sequence: UInt16, to address: String) {
        fatalError("TODO: implement ``ICMPEchoRepository/send(identifier:sequence:to:)``")
    }
}

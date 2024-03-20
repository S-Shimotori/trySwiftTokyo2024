//
//  ICMPEchoRepository.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/03.
//

import Combine

protocol ICMPEchoRepositoryProtocol {
    var resultPublisher: AnyPublisher<ICMPEchoResult, any Error> { get }

    func sendRequest(identifier: UInt16, sequenceNumber: UInt16, to address: String)
}

// MARK: - ICMPEchoRepository

class ICMPEchoRepository {
    private let udpConnection: any UDPConnectionProtocol
    private let resultSubject = PassthroughSubject<ICMPEchoResult, Error>()

    init(udpConnection: some UDPConnectionProtocol) {
        self.udpConnection = udpConnection
    }

    func readICMPEchoReply(from message: IPMessage) -> ICMPEchoResult {
        let ttl: UInt8
        switch message.header {
        case let .v4(ipProtocol: ipProtocol, timeToLive: timeToLive, option: _):
            guard ipProtocol == .icmp else {
                fatalError("TODO: handle other types of messages")
            }
            ttl = timeToLive
        }

        guard let icmpEchoHeader = ICMPEchoHeader(message.data) else {
            return .error(NetworkError.invalidICMPEchoHeader)
        }

        // TODO: Stop stopwatch and calculate RTT

        let startIndexOfPayloadData = message.data.index(message.data.startIndex, offsetBy: MemoryLayout<ICMPEchoHeader>.size)
        let endIndexOfPayloadData = message.data.index(message.data.endIndex, offsetBy: 0)
        let payloadData = MemoryLayout<ICMPEchoHeader>.size < message.data.count
            ? message.data[startIndexOfPayloadData ..< endIndexOfPayloadData]
            : nil

        return .reply(
            sourceAddress: message.sourceAddress,
            identifier: icmpEchoHeader.identifier,
            sequenceNumber: icmpEchoHeader.sequenceNumber,
            ttl: ttl,
            rtt: .nan, // TODO: Pass RTT
            data: payloadData
        )
    }
}

// MARK: extension (ICMPEchoRepositoryProtocol)

extension ICMPEchoRepository: ICMPEchoRepositoryProtocol {
    var resultPublisher: AnyPublisher<ICMPEchoResult, Error> {
        resultSubject.eraseToAnyPublisher()
    }

    func sendRequest(identifier: UInt16, sequenceNumber: UInt16, to address: String) {
        fatalError("TODO: implement ``ICMPEchoRepository/send(identifier:sequence:to:)``")
    }
}

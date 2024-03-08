//
//  ICMPEchoResult.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/03.
//

import Foundation

enum ICMPEchoResult {
    /// - Parameters:
    ///   - sourceAddress: Who sent this reply.
    ///   - identifier: The identifier of this reply.
    ///   - sequenceNumber: The sequence number of this reply.
    ///   - rtt: Round Trip Time until this reply was received.
    ///   - data: Payload data.
    case reply(sourceAddress: in_addr, identifier: UInt16, sequenceNumber: UInt16, rtt: TimeInterval, data: Data?)

    /// - Parameters:
    ///   - identifier: The identifier of the request.
    ///   - sequenceNumber: The sequence number of the request.
    case timeout(identifier: UInt16, sequenceNumber: UInt16)

    case error(any Error)
}

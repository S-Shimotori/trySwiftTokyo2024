//
//  IPMessage.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/04.
//

import Foundation

/// - ToDo: Support IPv6 header
struct IPMessage {
    enum Header {
        case v4(ipProtocol: IPProtocol, timeToLive: UInt8, option: Data?)
    }

    let header: Header
    let sourceAddress: in_addr
    let destinationAddress: in_addr

    let data: Data

    // MARK: Initializer

    /// Creates an instance from binary data.
    init(_ data: Data) throws {
        // validate the length of given data

        let minimumLengthOfIPv4Header = MemoryLayout<IPv4Header>.size
        guard minimumLengthOfIPv4Header <= data.count,
              let ipv4Header = IPv4Header(Data(data[0 ..< minimumLengthOfIPv4Header])) else {
            fatalError("TODO: handle wrong format")
        }

        let lengthOfIPv4Header = ipv4Header.ihl * 4
        guard lengthOfIPv4Header < data.count else {
            fatalError("TODO: handle wrong format")
        }

        // retrieve parameters

        let option: Data? = minimumLengthOfIPv4Header < lengthOfIPv4Header
            ? Data(data[minimumLengthOfIPv4Header ..< lengthOfIPv4Header])
            : nil
        self.header = .v4(
            ipProtocol: ipv4Header.protocol,
            timeToLive: ipv4Header.timeToLive,
            option: option
        )
        self.sourceAddress = ipv4Header.sourceIPAddress
        self.destinationAddress = ipv4Header.destinationIPAddress
        self.data = data[lengthOfIPv4Header ..< data.count]
    }
}

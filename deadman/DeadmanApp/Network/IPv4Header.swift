//
//  IPv4Header.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/03.
//

import Foundation

struct IPv4Header {
    let vhl: UInt8
    let typeOfService: UInt8
    private let _totalLength: UInt16
    private let _identification: UInt16
    private let _offset: UInt16
    let timeToLive: UInt8
    let `protocol`: IPProtocol
    private let _checksum: UInt16
    let sourceIPAddress: in_addr
    let destinationIPAddress: in_addr

    // TODO: properties to retrieve values larger than 1 byte

    var ihl: Int {
        Int(vhl & 0xF)
    }

    // MARK: Initializers

    init?(_ data: Data) {
        guard MemoryLayout<Self>.size <= data.count else {
            return nil
        }

        self = data.withUnsafeBytes {
            $0.load(as: IPv4Header.self)
        }
    }
}

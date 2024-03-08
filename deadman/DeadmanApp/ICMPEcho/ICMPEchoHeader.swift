//
//  ICMPEchoHeader.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/03.
//

import Foundation

struct ICMPEchoHeader {
    let type: ICMPType
    let code: UInt8
    let checksum: UInt16
    private let _identifier: UInt16
    private let _sequenceNumber: UInt16

    var identifier: UInt16 {
        _identifier.byteSwapped
    }

    var sequenceNumber: UInt16 {
        _sequenceNumber.byteSwapped
    }

    // MARK: Initializers

    private init(type: ICMPType, identifier: UInt16, sequenceNumber: UInt16) {
        self.type = type
        self.code = 0
        self._identifier = identifier.bigEndian
        self._sequenceNumber = sequenceNumber.bigEndian

        let typeCode = Data([
            self.type.rawValue,
            self.code
        ]).withUnsafeBytes {
            $0.load(as: UInt16.self)
        }
        self.checksum = [
            typeCode,
            self._identifier,
            self._sequenceNumber
        ].map {
            UInt64($0)
        }.internetChecksum
    }

    init?(_ data: Data) {
        guard MemoryLayout<Self>.size <= data.count else {
            return nil
        }

        self = data.withUnsafeBytes {
            $0.load(as: ICMPEchoHeader.self)
        }

        guard type == .echoReply || type == .echoRequest else {
            return nil
        }
        guard code == 0 else {
            return nil
        }
    }
}

extension ICMPEchoHeader {
    static func request(identifier: UInt16, sequenceNumber: UInt16) -> ICMPEchoHeader {
        .init(type: .echoRequest, identifier: identifier, sequenceNumber: sequenceNumber)
    }
}

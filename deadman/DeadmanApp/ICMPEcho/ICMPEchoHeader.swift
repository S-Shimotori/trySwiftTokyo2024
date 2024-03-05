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
    private let _id: UInt16
    private let _sequence: UInt16

    var id: UInt16 {
        _id.byteSwapped
    }

    var sequence: UInt16 {
        _sequence.byteSwapped
    }

    // MARK: Initializers

    private init(type: ICMPType, id: UInt16, sequence: UInt16) {
        self.type = type
        self.code = 0
        self._id = id.bigEndian
        self._sequence = sequence.bigEndian

        let typeCode = Data([
            self.type.rawValue,
            self.code
        ]).withUnsafeBytes {
            $0.load(as: UInt16.self)
        }
        self.checksum = [
            typeCode,
            self._id,
            self._sequence
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
    static func request(id: UInt16, sequence: UInt16) -> ICMPEchoHeader {
        .init(type: .echoRequest, id: id, sequence: sequence)
    }
}

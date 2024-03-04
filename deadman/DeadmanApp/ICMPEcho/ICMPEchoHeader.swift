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
    let id: UInt16
    let sequence: UInt16

    // MARK: Initializers

    private init(type: ICMPType, id: UInt16, sequence: UInt16) {
        self.type = type
        self.code = 0
        self.id = id.bigEndian
        self.sequence = sequence.bigEndian

        let typeCode = Data([
            self.type.rawValue,
            self.code
        ]).withUnsafeBytes {
            $0.load(as: UInt16.self)
        }
        self.checksum = [
            typeCode,
            self.id,
            self.sequence
        ].map {
            UInt64($0)
        }.internetChecksum
    }
}

extension ICMPEchoHeader {
    static func request(id: UInt16, sequence: UInt16) -> ICMPEchoHeader {
        .init(type: .echoRequest, id: id, sequence: sequence)
    }
}

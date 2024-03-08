//
//  ICMPEchoRequest.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/03.
//

import Foundation

struct ICMPEchoRequest {
    let header: ICMPEchoHeader

    /// - ToDo: Support variable-length payload
    let payload: (Int64, Int64, Int64, Int64, Int64, Int64, Int64) = (0, 0, 0, 0, 0, 0, 0)

    init(identifier: UInt16, sequenceNumber: UInt16) {
        self.header = ICMPEchoHeader.request(
            identifier: identifier,
            sequenceNumber: sequenceNumber
        )
    }

    var rawData: Data {
        var bytes = self
        return Data(bytes: &bytes, count: MemoryLayout<Self>.size)
    }
}

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

    init(id: UInt16, sequence: UInt16) {
        self.header = ICMPEchoHeader.request(
            id: id,
            sequence: sequence
        )
    }

    var rawData: Data {
        var bytes = self
        return Data(bytes: &bytes, count: MemoryLayout<Self>.size)
    }
}

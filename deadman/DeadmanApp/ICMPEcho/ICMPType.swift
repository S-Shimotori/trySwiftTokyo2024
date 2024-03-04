//
//  ICMPType.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/03/04.
//

import Foundation

struct ICMPType: RawRepresentable {
    let rawValue: UInt8
}

// MARK: List of IP protocols

extension ICMPType {
    static let echoReply = ICMPType(rawValue: UInt8(ICMP_ECHOREPLY))
    static let echoRequest = ICMPType(rawValue: UInt8(ICMP_ECHO))
}

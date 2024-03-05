//
//  IPProtocol.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/04.
//

import Foundation

/// IP protocol whose number is managed by IANA.
struct IPProtocol: RawRepresentable {
    let rawValue: UInt8
}

// MARK: List of IP protocols

extension IPProtocol {
    static let icmp = IPProtocol(rawValue: UInt8(IPPROTO_ICMP))
}

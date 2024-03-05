//
//  IPv4HeaderTests.swift
//  DeadmanAppTests
//
//  Created by S-Shimotori on 2024/03/05.
//

import XCTest
@testable import DeadmanApp

final class IPv4HeaderTests: XCTestCase {
    func testLoadData() throws {
        let ihl = UInt8(5) // 32bit * 5
        let vhl = UInt8(4 << 4) + ihl // version: 4
        let timeToLive = UInt8(64)
        let ipProtocol = IPProtocol.icmp

        let bytes: [UInt8] = [
            vhl,
            0, // type of service
            0b01000000, 0, // total length
            0b01100010, 0b01101101, // identification
            0, 0, // flags & fragment offset
            timeToLive,
            ipProtocol.rawValue, // protocol: ICMP
            0b10010100, 0b10110101, // checksum
        ]
        + [192, 168, 1, 1]
        + [192, 168, 1, 53]

        let actualIPv4Header = try XCTUnwrap(IPv4Header(Data(bytes)))
        XCTAssertEqual(actualIPv4Header.vhl, vhl)
        XCTAssertEqual(actualIPv4Header.ihl, Int(ihl))
        XCTAssertEqual(actualIPv4Header.timeToLive, timeToLive)
        XCTAssertEqual(actualIPv4Header.protocol.rawValue, ipProtocol.rawValue)
        XCTAssertEqual(try actualIPv4Header.sourceIPAddress.toString(), "192.168.1.1")
        XCTAssertEqual(try actualIPv4Header.destinationIPAddress.toString(), "192.168.1.53")
    }
}

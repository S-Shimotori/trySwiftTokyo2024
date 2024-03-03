//
//  InAddrTests.swift
//  DeadmanAppTests
//
//  Created by S-Shimotori on 2024/02/04.
//

import Foundation
import XCTest
@testable import DeadmanApp

final class InAddrTests: XCTestCase {
    func testToString() {
        let testCases: [ToStringTestCase] = [
            .init(input: 0x04030201, expected: "1.2.3.4"),
            .init(input: 0x00000000, expected: "0.0.0.0"),
            .init(input: 0xFFFFFFFF, expected: "255.255.255.255"),
            .init(input: 0x0100000A, expected: "10.0.0.1"),
            .init(input: 0x010010AC, expected: "172.16.0.1"),
            .init(input: 0x0100A8C0, expected: "192.168.0.1"),
        ]

        for testCase in testCases {
            var rawAddressData = testCase.input
            let address = Data(bytes: &rawAddressData, count: MemoryLayout<Int>.size).withUnsafeBytes {
                $0.load(as: in_addr.self)
            }

            XCTAssertEqual(try address.toString(), testCase.expected, line: testCase.line)
        }
    }

    private struct ToStringTestCase {
        let input: Int
        let expected: String

        let line: UInt

        init(input: Int, expected: String, line: UInt = #line) {
            self.input = input
            self.expected = expected
            self.line = line
        }
    }
}

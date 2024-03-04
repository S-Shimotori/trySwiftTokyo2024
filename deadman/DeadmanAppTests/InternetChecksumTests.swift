//
//  InternetChecksumTests.swift
//  DeadmanAppTests
//
//  Created by S-Shimotori on 2024/03/04.
//

import XCTest
@testable import DeadmanApp

final class InternetChecksumTests: XCTestCase {
    func testInternetChecksum() throws {
        let testCases: [InternetChecksumTestCase] = [
            .init(input: [0], expected: 0xFFFF),
            .init(input: [0x0], expected: 0xFFFF),
            .init(input: [0x1], expected: 0xFFFE),
            .init(input: [0x2], expected: 0xFFFD),
            .init(input: [0x1, 0x1], expected: 0xFFFD),
            .init(input: [0x10000], expected: 0xFFFE),
            .init(input: [0x10001], expected: 0xFFFD),
            .init(input: [0x10000, 0x1], expected: 0xFFFD),
        ]

        for testCase in testCases {
            XCTAssertEqual(testCase.input.internetChecksum, testCase.expected, line: testCase.line)
        }
    }

    private struct InternetChecksumTestCase {
        let input: [UInt64]
        let expected: UInt16

        let line: UInt

        init(input: [UInt64], expected: UInt16, line: UInt = #line) {
            self.input = input
            self.expected = expected
            self.line = line
        }
    }
}

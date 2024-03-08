//
//  ICMPEchoRequestTests.swift
//  DeadmanAppTests
//
//  Created by S-Shimotori on 2024/03/04.
//

import XCTest
@testable import DeadmanApp

final class ICMPEchoRequestTests: XCTestCase {
    func testRawData() {
        let testCases: [RawDataTestCase] = [
            .init(identifier: 1, sequenceNumber: 0, checksum: 0xF7FE),
            .init(identifier: 4, sequenceNumber: 5, checksum: 0xF7F6),
            .init(identifier: 1024, sequenceNumber: 1280, checksum: 0xEEFF),
        ]

        for testCase in testCases {
            XCTAssertEqual(testCase.input, testCase.expected, line: testCase.line)
        }
    }

    private struct RawDataTestCase {
        let input: Data
        let expected: Data

        let line: UInt

        init(identifier: UInt16, sequenceNumber: UInt16, checksum: UInt16, line: UInt = #line) {
            self.input = ICMPEchoRequest(identifier: identifier, sequenceNumber: sequenceNumber).rawData

            let expectedBytes: [UInt8] = [
                8, // type
                0, // code
            ]
            + [
                checksum,
                identifier,
                sequenceNumber,
            ].flatMap { [$0.upperBits, $0.lowerBits] }
            + Array(repeating: UInt8(0), count: 64 * 7 / 8) // payload
            self.expected = Data(expectedBytes)

            self.line = line
        }
    }
}

extension UInt16 {
    fileprivate var upperBits: UInt8 {
        UInt8(self >> 8)
    }

    fileprivate var lowerBits: UInt8 {
        UInt8(self & 0xFF)
    }
}

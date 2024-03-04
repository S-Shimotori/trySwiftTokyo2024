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
            .init(id: 1, sequence: 0, checksum: 0xF7FE),
            .init(id: 4, sequence: 5, checksum: 0xF7F6),
            .init(id: 1024, sequence: 1280, checksum: 0xEEFF),
        ]

        for testCase in testCases {
            XCTAssertEqual(testCase.input, testCase.expected, line: testCase.line)
        }
    }

    private struct RawDataTestCase {
        let input: Data
        let expected: Data

        let line: UInt

        init(id: UInt16, sequence: UInt16, checksum: UInt16, line: UInt = #line) {
            self.input = ICMPEchoRequest(id: id, sequence: sequence).rawData

            let expectedBytes: [UInt8] = [
                8, // type
                0, // code
            ]
            + [
                checksum, // checksum
                id, // identifier
                sequence, // sequence
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

//
//  ICMPEchoHeaderTests.swift
//  DeadmanAppTests
//
//  Created by S-Shimotori on 2024/03/05.
//

import XCTest
@testable import DeadmanApp

final class ICMPEchoHeaderTests: XCTestCase {
    func testLoadData() {
        let testCases: [LoadDataTestCase] = [
            // request
            .init(
                input: Data([UInt8(0x8), 0x0, 0xF7, 0xF6, 0x0, 0x4, 0x0, 0x5]),
                expected: (type: .echoRequest, code: 0, id: 4, sequence: 5)
            ),
            // reply
            .init(
                input: Data([UInt8(0x0), 0x0, 0xFF, 0xF6, 0x0, 0x4, 0x0, 0x5]),
                expected: (type: .echoReply, code: 0, id: 4, sequence: 5)
            ),
            // too short
            .init(
                input: Data([UInt8(0x8), 0x0, 0xF7, 0xF6, 0x0, 0x4, 0x0]),
                expected: nil
            ),
            // invalid type
            .init(
                input: Data([UInt8(13) /* timestamp */, 0x0, 0xF2, 0xF6, 0x0, 0x4, 0x0, 0x5]),
                expected: nil
            ),
            // invalid code
            .init(
                input: Data([UInt8(0x8), 0x1 /* undefined */, 0xF7, 0xF5, 0x0, 0x4, 0x0, 0x5]),
                expected: nil
            ),
        ]

        for testCase in testCases {
            let header = ICMPEchoHeader(testCase.input)
            XCTAssertEqual(header?.type.rawValue, testCase.expected?.type.rawValue, line: testCase.line)
            XCTAssertEqual(header?.code, testCase.expected?.code, line: testCase.line)
            XCTAssertEqual(header?.id, testCase.expected?.id.byteSwapped, line: testCase.line)
            XCTAssertEqual(header?.sequence, testCase.expected?.sequence.byteSwapped, line: testCase.line)

            if var header {
                XCTAssertEqual(
                    testCase.input,
                    Data(bytes: &header, count: MemoryLayout<ICMPEchoHeader>.size),
                    line: testCase.line
                )
            }
        }
    }

    private struct LoadDataTestCase {
        let input: Data
        let expected: (type: ICMPType, code: UInt8, id: UInt16, sequence: UInt16)?

        let line: UInt

        init(input: Data, expected: (type: ICMPType, code: UInt8, id: UInt16, sequence: UInt16)?, line: UInt = #line) {
            self.input = input
            self.expected = expected
            self.line = line
        }
    }
}

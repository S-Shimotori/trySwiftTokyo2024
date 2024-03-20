//
//  ICMPEchoRepositoryTests.swift
//  DeadmanAppTests
//
//  Created by S-Shimotori on 2024/03/08.
//

import XCTest
import Combine
@testable import DeadmanApp

final class ICMPEchoRepositoryTests: XCTestCase {
    func testReadICMPEchoReply() throws {
        let testCases: [ReadICMPEchoReplyTestCase] = [
            // no ICMP Echo data
            .init(
                input: try .init(
                    data: .init([
                        // IPv4 header
                        0b01000101, 0b00000000, 0b01000000, 0b00000000,
                        0b10110011, 0b10110110, 0b00000000, 0b00000000,
                        0b01000000, 0b00000001, 0b01000011, 0b01101011,
                        0b11000000, 0b10101000, 0b00000001, 0b00000001,
                        0b11000000, 0b10101000, 0b00000001, 0b00110110,
                    ]),
                    receivedDate: .distantPast
                ),
                expected: .error(NetworkError.invalidICMPEchoHeader)
            ),
            // no payload data
            .init(
                input: try .init(
                    data: .init([
                        // IPv4 header
                        0b01000101, 0b00000000, 0b01000000, 0b00000000,
                        0b01100010, 0b11001000, 0b00000000, 0b00000000,
                        0b01000000, 0b00000001, 0b00000000, 0b00000000,
                        0b01111111, 0b00000000, 0b00000000, 0b00000001,
                        0b01111111, 0b00000000, 0b00000000, 0b00000001,
                        // ICMP Echo header
                        0b00000000, 0b00000000, 0b11100100, 0b00010001,
                        0b00000111, 0b01011001, 0b00010100, 0b10010101,
                    ]),
                    receivedDate: .distantPast
                ),
                expected: .reply(
                    sourceAddress: .init(s_addr: UInt32(0b01111111_00000000_00000000_00000001).bigEndian), // 127.0.0.1
                    identifier: 1881, // 0b11101011001
                    sequenceNumber: 5269, // 0b1010010010101
                    ttl: 64,
                    rtt: .nan,
                    data: nil
                )
            ),
            // payload data
            .init(
                input: try .init(
                    data: .init([
                        // IPv4 header
                        0b01000101, 0b00000000, 0b01000000, 0b00000000,
                        0b01100010, 0b11001000, 0b00000000, 0b00000000,
                        0b01000000, 0b00000001, 0b00000000, 0b00000000,
                        0b01111111, 0b00000000, 0b00000000, 0b00000001,
                        0b01111111, 0b00000000, 0b00000000, 0b00000001,
                        // ICMP Echo header
                        0b00000000, 0b00000000, 0b11100100, 0b00010001,
                        0b00000111, 0b01011001, 0b00010100, 0b10010101,
                        // payload
                        0b00000000, 0b00000000, 0b00000000, 0b00000000,
                        0b00000000, 0b00000000, 0b00000000, 0b00000000,
                        0b00000000, 0b00000000, 0b00000000, 0b00000000,
                        0b00000000, 0b00000000, 0b00000000, 0b00000000,
                        0b00000000, 0b00000000, 0b00000000, 0b00000000,
                        0b00000000, 0b00000000, 0b00000000, 0b00000000,
                        0b00000000, 0b00000000, 0b00000000, 0b00000000,
                    ]),
                    receivedDate: .distantPast
                ),
                expected: .reply(
                    sourceAddress: .init(s_addr: UInt32(0b01111111_00000000_00000000_00000001).bigEndian), // 127.0.0.1
                    identifier: 1881, // 0b11101011001
                    sequenceNumber: 5269, // 0b1010010010101
                    ttl: 64,
                    rtt: .nan,
                    data: .init([
                        0b00000000, 0b00000000, 0b00000000, 0b00000000,
                        0b00000000, 0b00000000, 0b00000000, 0b00000000,
                        0b00000000, 0b00000000, 0b00000000, 0b00000000,
                        0b00000000, 0b00000000, 0b00000000, 0b00000000,
                        0b00000000, 0b00000000, 0b00000000, 0b00000000,
                        0b00000000, 0b00000000, 0b00000000, 0b00000000,
                        0b00000000, 0b00000000, 0b00000000, 0b00000000,
                    ])
                )
            ),
        ]

        let icmpEchoRepository = ICMPEchoRepository(udpConnection: TestUDPConnection())
        for testCase in testCases {
            self.assert(
                lhs: icmpEchoRepository.readICMPEchoReply(from: testCase.input),
                rhs: testCase.expected,
                line: testCase.line
            )
        }
    }

    private func assert(lhs: ICMPEchoResult, rhs: ICMPEchoResult, line: UInt) {
        switch (lhs, rhs) {
        case let (
            .reply(sourceAddress: lhsSourceAddress, identifier: lhsIdentifier, sequenceNumber: lhsSequenceNumber, ttl: lhsTTL, rtt: lhsRTT, data: lhsData),
            .reply(sourceAddress: rhsSourceAddress, identifier: rhsIdentifier, sequenceNumber: rhsSequenceNumber, ttl: rhsTTL, rtt: rhsRTT, data: rhsData)
        ):
            XCTAssertEqual(lhsSourceAddress.s_addr, rhsSourceAddress.s_addr, "source address", line: line)
            XCTAssertEqual(lhsIdentifier, rhsIdentifier, "identifier", line: line)
            XCTAssertEqual(lhsSequenceNumber, rhsSequenceNumber, "sequence number", line: line)
            XCTAssertEqual(lhsTTL, rhsTTL, "TTL", line: line)
            // TODO: Check RTT
//            XCTAssertEqual(lhsRTT, rhsRTT, "RTT", line: line)
            XCTAssertEqual(lhsData, rhsData, "payload data", line: line)
        case let (
            .timeout(identifier: lhsIdentifier, sequenceNumber: lhsSequenceNumber),
            .timeout(identifier: rhsIdentifier, sequenceNumber: rhsSequenceNumber)
        ):
            XCTAssertEqual(lhsIdentifier, rhsIdentifier, "identifier", line: line)
            XCTAssertEqual(lhsSequenceNumber, rhsSequenceNumber, "sequence number", line: line)
        case let (.error(lhsNetworkError as NetworkError), .error(rhsNetworkError as NetworkError)):
            XCTAssertEqual(lhsNetworkError , rhsNetworkError, line: line)
        case (.error(_), .error(_)):
            XCTFail("Unexpected error", line: line)
        default:
            XCTFail("Wrong result", line: line)
        }
    }

    private struct ReadICMPEchoReplyTestCase {
        let input: IPMessage
        let expected: ICMPEchoResult

        let line: UInt

        init(input: IPMessage, expected: ICMPEchoResult, line: UInt = #line) {
            self.input = input
            self.expected = expected
            self.line = line
        }
    }
}

private struct TestUDPConnection: UDPConnectionProtocol {
    let receivedMessagePublisher: AnyPublisher<IPMessage, any Error> = Future { _ in }.eraseToAnyPublisher()

    func send(message: Data, to address: String) throws {}

    func beginPollingMessages() {}

    func stopPollingMessages() {}
}

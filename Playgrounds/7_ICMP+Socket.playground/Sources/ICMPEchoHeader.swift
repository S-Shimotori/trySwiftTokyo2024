import Foundation

public struct ICMPEchoHeader {
    public let type: ICMPType
    let code: UInt8
    let checksum: UInt16
    private let _identifier: UInt16
    private let _sequenceNumber: UInt16

    public var identifier: UInt16 {
        _identifier.byteSwapped
    }

    public var sequenceNumber: UInt16 {
        _sequenceNumber.byteSwapped
    }

    // MARK: Initializers

    init(type: ICMPType, identifier: UInt16, sequenceNumber: UInt16) {
        self.type = type
        self.code = 0
        self._identifier = identifier.bigEndian
        self._sequenceNumber = sequenceNumber.bigEndian

        let typeCode = Data([
            self.type.rawValue,
            self.code
        ]).withUnsafeBytes {
            $0.load(as: UInt16.self)
        }
        self.checksum = [
            typeCode,
            self._identifier,
            self._sequenceNumber
        ].map {
            UInt64($0)
        }.checksum
    }

    public init?(_ data: Data) {
        guard MemoryLayout<Self>.size <= data.count else {
            return nil
        }

        self = data.withUnsafeBytes {
            $0.load(as: ICMPEchoHeader.self)
        }

        guard type == .echoReply || type == .echoRequest else {
            return nil
        }
        guard code == 0 else {
            return nil
        }
    }
}

extension [UInt64] {
    var checksum: UInt16 {
        var sum = reduce(0, +)
        while sum >> 16 != 0 {
            let last16Digits = sum & 0xFFFF
            sum = last16Digits + (sum >> 16)
        }
        return ~UInt16(sum)
    }
}

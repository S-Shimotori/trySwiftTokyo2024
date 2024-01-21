import Foundation

public struct ICMPEchoHeader {
    let type: UInt8
    let code: UInt8
    let checksum: UInt16
    let id: UInt16
    let sequence: UInt16

    public init(id: UInt16, sequence: UInt16) {
        self.type = UInt8(ICMP_ECHO)
        self.code = 0
        self.id = id.bigEndian
        self.sequence = sequence.bigEndian

        let typeCode = Data([
            self.type,
            self.code
        ]).withUnsafeBytes {
            $0.load(as: UInt16.self)
        }
        self.checksum = [
            typeCode,
            self.id,
            self.sequence
        ].map {
            UInt64($0)
        }.checksum
    }

    public init?(_ data: Data) {
        guard data.count >= MemoryLayout<Self>.size else {
            return nil
        }

        self = data.withUnsafeBytes {
            $0.load(as: ICMPEchoHeader.self)
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

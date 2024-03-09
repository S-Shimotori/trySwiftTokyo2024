import Foundation

public struct IPv4Header {
    let vhl: UInt8
    let typeOfService: UInt8
    private let _totalLength: UInt16
    private let _identification: UInt16
    private let _offset: UInt16
    let timeToLive: UInt8
    let `protocol`: IPProtocol
    private let _checksum: UInt16
    let sourceIPAddress: in_addr
    let destinationIPAddress: in_addr

    public init?(_ data: Data) {
        guard data.count >= MemoryLayout<Self>.size else {
            return nil
        }

        self = data.withUnsafeBytes {
            $0.load(as: IPv4Header.self)
        }
    }
}

extension IPv4Header {
    public var ihl: Int {
        Int(vhl & 0xF)
    }
}

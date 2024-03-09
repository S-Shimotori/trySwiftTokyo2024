import Foundation

public struct ICMPType: RawRepresentable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

// MARK: List of IP protocols

extension ICMPType {
    static let echoReply = ICMPType(rawValue: UInt8(ICMP_ECHOREPLY))
    static let echoRequest = ICMPType(rawValue: UInt8(ICMP_ECHO))
}

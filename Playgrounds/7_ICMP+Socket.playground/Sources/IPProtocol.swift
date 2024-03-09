import Foundation

/// IP protocol whose number is managed by IANA.
public struct IPProtocol: RawRepresentable {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

// MARK: List of IP protocols

extension IPProtocol {
    static let icmp = IPProtocol(rawValue: UInt8(IPPROTO_ICMP))
}

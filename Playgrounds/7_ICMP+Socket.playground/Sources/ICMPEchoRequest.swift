import Foundation

public struct ICMPEchoRequest {
    let header: ICMPEchoHeader
    let payload: (Int64, Int64, Int64, Int64, Int64, Int64, Int64) = (0, 0, 0, 0, 0, 0, 0)

    public init(identifier: UInt16, sequenceNumber: UInt16) {
        self.header = ICMPEchoHeader(
            type: .echoRequest,
            identifier: identifier,
            sequenceNumber: sequenceNumber
        )
    }

    public var rawData: Data {
        var bytes = self
        return Data(bytes: &bytes, count: MemoryLayout<Self>.size)
    }
}

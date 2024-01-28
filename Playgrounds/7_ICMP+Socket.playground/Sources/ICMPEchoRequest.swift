import Foundation

public struct ICMPEchoRequest {
    let header: ICMPEchoHeader
    let payload: (Int64, Int64, Int64, Int64, Int64, Int64, Int64) = (0, 0, 0, 0, 0, 0, 0)

    public init(id: UInt16, sequence: UInt16) {
        self.header = ICMPEchoHeader(
            id: id,
            sequence: sequence
        )
    }

    public var rawData: Data {
        var bytes = self
        return Data(bytes: &bytes, count: MemoryLayout<Self>.size)
    }
}

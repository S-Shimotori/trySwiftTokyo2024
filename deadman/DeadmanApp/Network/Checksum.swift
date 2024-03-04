//
//  Checksum.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/03/04.
//

extension [UInt64] {
    /// A checksum of this array.
    ///
    /// > Definition:
    /// > The checksum field is the 16 bit one's complement of the one's complement sum of all 16 bit words in the header.
    var internetChecksum: UInt16 {
        let bitWidth = 16
        let wordBitMask = UInt64(0xFFFF)

        var sum = reduce(0, +)
        while sum >> bitWidth != 0 {
            let word = sum & wordBitMask
            sum = word + (sum >> bitWidth)
        }

        return ~UInt16(sum)
    }
}

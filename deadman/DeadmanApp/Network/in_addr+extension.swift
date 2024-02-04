//
//  in_addr+extension.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/04.
//

import Foundation

extension in_addr {
    /// Converts IP address from binary to string form.
    /// - Returns: The string representation of the value.
    /// - throws: `POSIXError` when fails to convert.
    /// - ToDo: Supports IPv6 address
    func toString() throws -> String {
        var pointerToStringAddress = Array(repeating: CChar(), count: Int(INET_ADDRSTRLEN))

        // `pointer` will receive the same pointer as `pointerToStringAddress`.
        let pointer = withUnsafePointer(to: self) { pointerToSinAddr in
            pointerToStringAddress.withUnsafeMutableBufferPointer { mutableBufferPointerToStringAddress in
                inet_ntop(
                    AF_INET,
                    UnsafeRawPointer(pointerToSinAddr),
                    mutableBufferPointerToStringAddress.baseAddress,
                    socklen_t(INET_ADDRSTRLEN)
                )
            }
        }

        guard pointer != nil else {
            guard let code = POSIXErrorCode(rawValue: errno) else {
                fatalError("TODO: handle unknown error")
            }
            throw POSIXError(code)
        }

        return String(cString: pointerToStringAddress)
    }
}

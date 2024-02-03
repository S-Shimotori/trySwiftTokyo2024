//
//  FileDescriptor.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/03.
//

import Foundation

struct FileDescriptor: ~Copyable {
    private let fd: Int32

    init() {
        fatalError("TODO: implement ``FileDescriptor/init``")
    }

    deinit {
        fatalError("TODO: implement ``FileDescriptor/deinit``")
    }

    func send(message: Data, to internetAddress: sockaddr_in) throws {
        fatalError("TODO: implement ``FileDescriptor/send(message:to:)``")
    }

    func poll() async throws -> Bool {
        fatalError("TODO: implement ``FileDescriptor/poll()``")
    }

    func recvfrom() throws -> Data {
        fatalError("TODO: implement ``FileDescriptor/recvfrom()``")
    }

    consuming func close() throws {
        fatalError("TODO: implement ``FileDescriptor/close()``")
    }
}

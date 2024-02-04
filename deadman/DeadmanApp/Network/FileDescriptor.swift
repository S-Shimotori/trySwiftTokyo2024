//
//  FileDescriptor.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/03.
//

import Foundation

struct FileDescriptor: ~Copyable {
    private let fd: Int32

    init(fd: Int32) {
        self.fd = fd
    }

    deinit {
        // discard result because `deinit` cannot throw an error
        _ = Darwin.close(fd)
    }

    func send(message: Data, to internetAddress: sockaddr_in) throws {
        let lengthOfSentMessage = message.withUnsafeBytes { rawBufferPointerToMessage in
            withUnsafePointer(to: internetAddress) { pointerToInternetAddress in
                pointerToInternetAddress.withMemoryRebound(to: sockaddr.self, capacity: 1) { pointerToAddress in
                    sendto(
                        fd,
                        rawBufferPointerToMessage.baseAddress,
                        message.count,
                        0,
                        pointerToAddress,
                        socklen_t(internetAddress.sin_len)
                    )
                }
            }
        }

        if lengthOfSentMessage < 0 {
            guard let code = POSIXErrorCode(rawValue: errno) else {
                fatalError("TODO: handle unknown error")
            }
            throw POSIXError(code)
        }
    }

    func poll() async throws {
        var pollfds = [pollfd(fd: fd, events: Int16(POLLIN), revents: 0)]
        while true {
            let result = Darwin.poll(&pollfds, 1, 1)
            guard result != -1 else {
                guard let code = POSIXErrorCode(rawValue: errno) else {
                    fatalError("TODO: handle unknown error")
                }
                throw POSIXError(code)
            }
            guard result != 0 else {
                // timeout
                continue
            }

            let revents = Int32(pollfds[0].revents)
            guard revents & POLLHUP != POLLHUP else {
                fatalError("TODO: handle POLLHUP")
            }
            guard revents & POLLERR != POLLERR else {
                fatalError("TODO: handle POLLERR")
            }
            guard revents & POLLNVAL != POLLNVAL else {
                fatalError("TODO: handle POLLNVAL")
            }
            guard revents & POLLIN == POLLIN else {
                fatalError("TODO: handle unknown error")
            }
            break
        }
    }

    func recvfrom() throws -> ReceivedSocketMessage {
        let lengthOfBuffer = Int(BUFSIZ)

        var receivedData = Data(Array(repeating: UInt8(0), count: lengthOfBuffer))
        var sizeOfInternetAddress = socklen_t(MemoryLayout<sockaddr_in>.size)
        var sourceAddress = sockaddr_in()

        let lengthOfReceivedMessage = withUnsafeMutablePointer(to: &sourceAddress) { mutablePointerToSourceAddress in
            mutablePointerToSourceAddress.withMemoryRebound(
                to: sockaddr.self,
                capacity: 1
            ) { mutablePointerToAddress in
                receivedData.withUnsafeMutableBytes { unsafeRawBufferPointerToReceivedData in
                    Darwin.recvfrom(
                        fd,
                        unsafeRawBufferPointerToReceivedData.baseAddress,
                        lengthOfBuffer,
                        0,
                        mutablePointerToAddress,
                        &sizeOfInternetAddress
                    )
                }
            }
        }

        guard lengthOfReceivedMessage >= 0 else {
            guard let code = POSIXErrorCode(rawValue: errno) else {
                fatalError("TODO: handle unknown error")
            }
            throw POSIXError(code)
        }

        return .init(sourceAddress: sourceAddress, rawData: receivedData[0 ..< lengthOfReceivedMessage])
    }

    consuming func close() throws {
        let fd = fd
        discard self

        if Darwin.close(fd) != 0 {
            // DO NOT retry close
            guard let code = POSIXErrorCode(rawValue: errno) else {
                fatalError("TODO: handle unknown error")
            }
            throw POSIXError(code)
        }
    }
}

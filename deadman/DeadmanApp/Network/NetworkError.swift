//
//  NetworkError.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/03/09.
//

/// Errors returned during network communication.
enum NetworkError: Error {
    /// An error that indicates the IP message has an invalid header.
    case invalidIPHeader
    /// An error that indicates the ICMP Echo message has invalid header.
    case invalidICMPEchoHeader
}

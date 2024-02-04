//
//  ReceivedSocketMessage.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/04.
//

import Foundation

/// A raw message received with internet domain socket.
struct ReceivedSocketMessage {
    let sourceAddress: sockaddr_in

    let rawData: Data
}

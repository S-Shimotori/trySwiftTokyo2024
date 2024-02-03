//
//  UDPConnection.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/03.
//

import Combine
import Foundation

protocol UDPConnectionProtocol {
    var receivedMessagePublisher: AnyPublisher<Data, any Error> { get }

    func send(message: Data, to: String) throws
}

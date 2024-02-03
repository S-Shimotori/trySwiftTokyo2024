//
//  ICMPEchoRepository.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/03.
//

import Combine

protocol ICMPEchoRepositoryProtocol {
    var resultPublisher: AnyPublisher<ICMPEchoResult, any Error> { get }

    func sendRequest(identifier: UInt16, sequence: UInt16, to address: String)
}

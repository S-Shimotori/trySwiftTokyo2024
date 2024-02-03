//
//  Ping.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/02/03.
//

protocol PingProtocol {
    // TODO: add a property to manage target addresses
    // TODO: add a property to handle ICMP Echo Request sequence
    // TODO: add a property to store results

    func start()
    func stop()
    func clear()
}

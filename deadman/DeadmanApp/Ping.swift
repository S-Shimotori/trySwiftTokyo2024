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

// MARK: - Ping

class Ping {
    private let icmpEchoRepository: any ICMPEchoRepositoryProtocol

    init(icmpEchoRepository: some ICMPEchoRepositoryProtocol) {
        self.icmpEchoRepository = icmpEchoRepository
    }
}

// MARK: extension (PingProtocol)

extension Ping: PingProtocol {
    func start() {
        fatalError("TODO: implement ``Ping/start``")
    }

    func stop() {
        fatalError("TODO: implement ``Ping/stop``")
    }

    func clear() {
        fatalError("TODO: implement ``Ping/clear``")
    }
}

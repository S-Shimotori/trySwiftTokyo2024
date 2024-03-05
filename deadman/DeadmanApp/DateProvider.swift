//
//  DateProvider.swift
//  DeadmanApp
//
//  Created by S-Shimotori on 2024/03/06.
//

import Foundation

// MARK: - DateProviderProtocol

protocol DateProviderProtocol {
    var now: Date { get }
}

// MARK: - DateProvider

struct DateProvider {}

extension DateProvider : DateProviderProtocol {
    var now: Date {
        Date.now
    }
}

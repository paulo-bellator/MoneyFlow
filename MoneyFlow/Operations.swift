//
//  Operations.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

protocol Operation {
    var date: Date { get }
    var value: Double { get }
    var currency: Currency { get }
    var account: String { get }
}

extension FlowOperation: Operation {}
extension DebtOperation: Operation {}


class Operations
{
    static let shared = Operations()
    
    private var operations: [Operation]
    private let defaults = UserDefaults()
    
    private init() {
        operations = (defaults.array(forKey: Constants.operationsUserDefaultsKey) as? [Operation]) ?? [Operation]()
    }
    deinit {
        defaults.set(operations, forKey: Constants.operationsUserDefaultsKey)
    }
    
    
    
    /// Return all operations in given boundaries (included)
    func all(since: Date? = nil, until: Date? = nil) -> [Operation] {
        var result = operations
        if let startDate = since {
            result = result.filter { $0.date >= startDate }
        }
        if let endDate = until {
            result = result.filter { $0.date <= endDate }
        }
        return result
    }
    
    /// Return debt operations operations in given boundaries (included)
    func debtOperations(since: Date? = nil, until: Date? = nil) -> [Operation] {
        var result = operations.filter { $0 is DebtOperation }
        if let startDate = since {
            result = result.filter { $0.date >= startDate }
        }
        if let endDate = until {
            result = result.filter { $0.date <= endDate }
        }
        return result
    }
    
    /// Return flow operations in given boundaries (included)
    func flowOperations(since: Date? = nil, until: Date? = nil) -> [Operation] {
        var result = operations.filter { $0 is FlowOperation }
        if let startDate = since {
            result = result.filter { $0.date >= startDate }
        }
        if let endDate = until {
            result = result.filter { $0.date <= endDate }
        }
        return result
    }
    
    
    
}

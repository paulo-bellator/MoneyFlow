//
//  Operations.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

protocol Operation: CustomStringConvertible {
    var id: Int { get }
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
    
    private var idForNextOperations: Int
    private var operations: [Operation]
    private let defaults = UserDefaults()
    
    // TODO: ID generator for operation
    
    private init() {
        operations = (defaults.array(forKey: Constants.operationsUserDefaultsKey) as? [Operation]) ?? [Operation]()
        idForNextOperations = defaults.integer(forKey: Constants.idForNextOperationsUserDefatultsKey)
    }
    deinit {
        defaults.set(operations, forKey: Constants.operationsUserDefaultsKey)
        defaults.set(idForNextOperations, forKey: Constants.idForNextOperationsUserDefatultsKey)
    }
    
    /// Return unique identifier for new operation
    func idGenerator() -> Int {
        let id = idForNextOperations
        idForNextOperations += 1
        return id
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
    
    func add(operation: Operation) {
        operations.append(operation)
    }
    
    func removeOperationWith(identifier: Int) {
        operations = operations.filter { $0.id != identifier }
    }
    
//    func change(value: Double, forIdentifier identifier: Int) {
//        for var operation in operations {
//            if operation.id == identifier {
//                operation.value = value
//            }
//        }
//    }
    
    func filter(since: Date? = nil, until: Date? = nil, debtOperations: Bool = true, flowOperations: Bool = true, currencies: [Currency]? = nil, categories: [String]? = nil, contacts: [String]? = nil, accounts: [String]? = nil) -> [Operation] {
        var result = operations
        if let startDate = since {
            result = result.filter { $0.date >= startDate }
        }
        if let endDate = until {
            result = result.filter { $0.date <= endDate }
        }
        if !debtOperations { result = result.filter { !($0 is DebtOperation) } }
        if !flowOperations { result = result.filter { !($0 is FlowOperation) } }
        if let requiredCurrencies = currencies {
            result = result.filter { requiredCurrencies.contains($0.currency) }
        }
        if let requiredAccounts = accounts {
            result = result.filter { requiredAccounts.contains($0.account) }
        }
        if let requiredCategories = categories {
            result = result.filter { ($0 is FlowOperation) && requiredCategories.contains(($0 as! FlowOperation).account) }
        }
        if let requiredContacts = contacts {
            result = result.filter { ($0 is DebtOperation) && requiredContacts.contains(($0 as! DebtOperation).contact) }
        }
        return result
    }
    
}

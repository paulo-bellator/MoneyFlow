//
//  Presenter.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

class Presenter {
    
    private var operations: [Operation] {
        return MainData.source.operations
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
        MainData.source.add(operation: operation)
    }
    
    func removeOperationWith(identifier: Int) {
        MainData.source.removeOperation(with: identifier)
    }
    
    func syncronize() {
        MainData.source.save()
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
            result = result.filter { ($0 is FlowOperation) && requiredCategories.contains(($0 as! FlowOperation).category) }
        }
        if let requiredContacts = contacts {
            result = result.filter { ($0 is DebtOperation) && requiredContacts.contains(($0 as! DebtOperation).contact) }
        }
        return result
    }
}

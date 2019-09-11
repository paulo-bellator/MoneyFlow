//
//  DefaultDataSource.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

class DefaultDataSource: OperationDataSource {
    
    static let shared = DefaultDataSource()
    
    var operations: [Operation] = []
    private let defaults = UserDefaults()
    private var thereAreUnsavedChanges = false
    
    func add(operation: Operation) {
        if !operations.contains(where: { $0.id == operation.id }) {
            operations.append(operation)
            thereAreUnsavedChanges = true
//            save()
        }
    }
    
    func removeOperation(with identifier: Int) {
        let previosCount = operations.count
        print(previosCount)
        operations = operations.filter { $0.id != identifier }
        if previosCount != operations.count { thereAreUnsavedChanges = true }
        print(operations.count)
//        save()
    }
    
    func save() {
        if thereAreUnsavedChanges {
            print("\nsaved\n")
            let encoder = JSONEncoder()
            let flowOperations = operations.filter { $0 is FlowOperation } as! [FlowOperation]
            let debtOperation = operations.filter { $0 is DebtOperation } as! [DebtOperation]
            if let encoded = try? encoder.encode(flowOperations) {
                defaults.set(encoded, forKey: UserDefaultsKeys.flowOperations)
            }
            if let encoded = try? encoder.encode(debtOperation) {
                defaults.set(encoded, forKey: UserDefaultsKeys.debtOperations)
            }
            thereAreUnsavedChanges = false
        } else {
            print("not saved: Data is actual")
        }
    }
    
    private init() {
        let decoder = JSONDecoder()
        var flowOperations = [Operation]()
        var debtOperations = [Operation]()
        
        if let data = defaults.data(forKey: UserDefaultsKeys.flowOperations) {
            flowOperations = (try? decoder.decode([FlowOperation].self, from: data)) ?? []
        }
        if let data = defaults.data(forKey: UserDefaultsKeys.debtOperations) {
            debtOperations = (try? decoder.decode([DebtOperation].self, from: data)) ?? []
        }
        operations = flowOperations + debtOperations
        if operations.isEmpty { operations += generateFlowOperations() + generateDebtOperations(); thereAreUnsavedChanges = true  }
    }
    
}

extension DefaultDataSource {
    private struct UserDefaultsKeys {
        static let flowOperations = "flowOperations"
        static let debtOperations = "debtOperations"
    }
}


private extension DefaultDataSource {
    
    private var currencies: [Currency] {
        return MainData.settings.currencies
    }
    private var outcomeCategories: [String] {
        return MainData.settings.outcomeCategories
    }
    private var incomeCategories: [String] {
        return MainData.settings.incomeCategories
    }
    private var contacts: [String] {
        return MainData.settings.contacts
    }
    private var accounts: [String] {
        return MainData.settings.accounts
    }
    
    private var randomValue: Double {
        return Double.random(in: -100000...100000)
    }
    
    private var comments: [String?] {
        return [nil, "Вика зубы", "За такси на тусу", "Не помню", "Вчера выиграл в покер, но нужно вернуть"]
    }
    
    
    private func generateFlowOperations() -> [FlowOperation] {
        var ops = [FlowOperation]()
        for _ in 1...500 {
            let date = Date() + TimeInterval(60*60*1*Int.random(in: -700...0))
            let value = randomValue
            let category = value < 0 ? outcomeCategories.randomElement()! : incomeCategories.randomElement()!
            let operation = FlowOperation(date: date, value: value, currency: currencies.randomElement()!, category: category, account: accounts.randomElement()!, comment: comments.randomElement()!)
            ops.append(operation)
        }
        return ops
    }
    private func generateDebtOperations() -> [DebtOperation] {
        var ops = [DebtOperation]()
        for _ in 1...50 {
            let date = Date() + TimeInterval(60*60*1*Int.random(in: -400...0))
            let operation = DebtOperation(date: date, value: randomValue, currency: currencies.randomElement()!, contact: contacts.randomElement()!, account: accounts.randomElement()!, comment: comments.randomElement()!)
            ops.append(operation)
        }
        return ops
    }
}



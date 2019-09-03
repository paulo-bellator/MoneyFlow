//
//  DefaultDataSource.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

class DefaultDataSource: DataSource {
    
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
        operations = operations.filter { $0.id != identifier }
        if previosCount != operations.count { thereAreUnsavedChanges = true }
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
        return [.eur, .rub, .usd]
    }
    private var categories: [String] {
        return ["Продукты", "Развлечения", "Здоровье", "Проезд", "Связь и интернет"]
    }
    private var contacts: [String] {
        return ["ООО МояРабота", "Вася", "Петя", "Тигран"]
    }
    private var accounts: [String] {
        return ["Наличные", "Сбербанк МСК", "Альфа", "Хоум Кредит", "Сбербанк РНД"]
    }
    
    private var randomValue: Double {
        return Double.random(in: -100000...100000)
    }
    
    
    private func generateFlowOperations() -> [FlowOperation] {
        var ops = [FlowOperation]()
        for _ in 1...30 {
            let operation = FlowOperation(date: Date(), value: randomValue, currency: currencies.randomElement()!, category: categories.randomElement()!, account: accounts.randomElement()!)
            ops.append(operation)
        }
        return ops
    }
    private func generateDebtOperations() -> [DebtOperation] {
        var ops = [DebtOperation]()
        for _ in 1...10 {
            let operation = DebtOperation(date: Date(), value: randomValue, currency: currencies.randomElement()!, contact: contacts.randomElement()!, account: accounts.randomElement()!)
            ops.append(operation)
        }
        return ops
    }
}



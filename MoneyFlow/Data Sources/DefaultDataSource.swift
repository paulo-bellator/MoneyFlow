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
    
    func add(operation: Operation) {
        if !operations.contains(where: { $0.id == operation.id }) {
            operations.append(operation)
//            save()
        }
    }
    
    func removeOperation(with identifier: Int) {
        operations = operations.filter { $0.id != identifier }
//        save()
    }
    
    func save() {
        let encoder = JSONEncoder()
        let flowOperations = operations.filter { $0 is FlowOperation } as! [FlowOperation]
        let debtOperation = operations.filter { $0 is DebtOperation } as! [DebtOperation]
        if let encoded = try? encoder.encode(flowOperations) {
            defaults.set(encoded, forKey: UserDefaultsKeys.flowOperations)
        }
        if let encoded = try? encoder.encode(debtOperation) {
            defaults.set(encoded, forKey: UserDefaultsKeys.debtOperations)
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
            debtOperations = (try? decoder.decode([FlowOperation].self, from: data)) ?? []
        }
        operations = flowOperations + debtOperations
    }
    
}

extension DefaultDataSource {
    private struct UserDefaultsKeys {
        static let flowOperations = "flowOperations"
        static let debtOperations = "debtOperations"
    }
}



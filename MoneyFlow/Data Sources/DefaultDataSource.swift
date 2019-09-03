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
            defaults.set(operations as Any, forKey: Constants.defaultDataSourceUserDefaultsKey)
        }
    }
    
    func removeOperation(with identifier: Int) {
        operations = operations.filter { $0.id != identifier }
        defaults.set(operations, forKey: Constants.defaultDataSourceUserDefaultsKey)
    }
    
    private init() {
        let data = defaults.data(forKey: Constants.defaultDataSourceUserDefaultsKey)
        if let data = data {
//            let decodedData = NSKeyedUnarchiver.unat
            
        }
        operations = defaults.array(forKey: Constants.defaultDataSourceUserDefaultsKey) as? [Operation] ?? []
    }
    
    private func saveInUserDefaults() {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: operations)
//        let encodedData = try! NSKeyedArchiver.archivedData(withRootObject: operations, requiringSecureCoding: false)
        defaults.set(encodedData, forKey: Constants.defaultDataSourceUserDefaultsKey)
    }
    
}



//
//  DataSource.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

protocol DataSource {
    var operations: [Operation] { get }
    func add(operation: Operation)
    func removeOperation(with identifier: Int)
    func save()
}

class MainData {
    static let source: DataSource = DefaultDataSource.shared
}


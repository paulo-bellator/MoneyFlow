//
//  DataSource.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

protocol OperationDataSource {
    var operations: [Operation] { get }
    func add(operation: Operation)
    func removeOperation(with identifier: Int)
    func save()
}

protocol SettingsDataSource {
    var categories: [String] { get }
    var contacts: [String] { get set }
    var accounts: [String] { get }
    var currencies: [Currency] { get }
    var emojiForCategory: [String: String] { get }
    var emojiForContact: [String: String] { get }
    
    func set(categories: [String])
    func set(contacts: [String])
    func set(accounts: [String])
    func set(currencies: [Currency])
    func set(emoji: String?, forCategory category: String)
    func set(emoji: String?, forContact contact: String)
    func save()
}

class MainData {
    static let source: OperationDataSource = DefaultDataSource.shared
    static let settings: SettingsDataSource = DefaultSettingsDataSource.shared
}


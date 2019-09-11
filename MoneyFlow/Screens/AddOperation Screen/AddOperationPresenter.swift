//
//  AddOperationPresenter.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 09/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation
import UIKit

class AddOperationPresenter {
    
    private let operations = MainData.source.operations
    
    private func testPrint(_ items: [String], _ frequencies: [Int]) {
        for index in items.indices {
            print("\(items[index]):  \(frequencies[index])")
        }
    }
    
    /// Return outcome categories sorted by frequency of use
    private(set) lazy var outcomeCategories: [String] = {
        var sortedCategories = MainData.settings.outcomeCategories
        var categoriesFrequency = Array(repeating: 0, count: sortedCategories.count)
        
        for op in operations.filter({ $0 is FlowOperation }) as! [FlowOperation] {
            if let index = sortedCategories.firstIndex(of: op.category) {
                categoriesFrequency[index] += 1
            }
        }

        return sortedCategories.sorted { op1, op2 in
            let indexOp1 = sortedCategories.firstIndex(of: op1)!
            let indexOp2 = sortedCategories.firstIndex(of: op2)!
            return categoriesFrequency[indexOp1] > categoriesFrequency[indexOp2]
        }
    }()
    
    /// Return income categories sorted by frequency of use
    private(set) lazy var incomeCategories: [String] = {
        var sortedCategories = MainData.settings.incomeCategories
        var categoriesFrequency = Array(repeating: 0, count: sortedCategories.count)
        
        for op in operations.filter({ $0 is FlowOperation }) as! [FlowOperation] {
            if let index = sortedCategories.firstIndex(of: op.category) {
                categoriesFrequency[index] += 1
            }
        }
        
        return sortedCategories.sorted { op1, op2 in
            let indexOp1 = sortedCategories.firstIndex(of: op1)!
            let indexOp2 = sortedCategories.firstIndex(of: op2)!
            return categoriesFrequency[indexOp1] > categoriesFrequency[indexOp2]
        }
    }()
    
    /// Return contacts sorted by frequency of use
    private(set) lazy var contacts: [String] = {
        var sortedContacts = MainData.settings.contacts
        var contactsFrequency = Array(repeating: 0, count: sortedContacts.count)
        
        for op in operations.filter({ $0 is DebtOperation }) as! [DebtOperation] {
            if let index = sortedContacts.firstIndex(of: op.contact) {
                contactsFrequency[index] += 1
            }
        }
        testPrint(sortedContacts, contactsFrequency)
        return sortedContacts.sorted { op1, op2 in
            let indexOp1 = sortedContacts.firstIndex(of: op1)!
            let indexOp2 = sortedContacts.firstIndex(of: op2)!
            return contactsFrequency[indexOp1] > contactsFrequency[indexOp2]
        }
    }()
    
    /// Return accounts sorted by frequency of use
    private(set) lazy var accounts: [String] = {
        var sortedAccounts = MainData.settings.accounts
        var accountsFrequency = Array(repeating: 0, count: sortedAccounts.count)
        
        for op in operations {
            if let index = sortedAccounts.firstIndex(of: op.account) {
                accountsFrequency[index] += 1
            }
        }
        return sortedAccounts.sorted { op1, op2 in
            let indexOp1 = sortedAccounts.firstIndex(of: op1)!
            let indexOp2 = sortedAccounts.firstIndex(of: op2)!
            return accountsFrequency[indexOp1] > accountsFrequency[indexOp2]
        }
    }()
    
    let currencies = MainData.settings.currencies
    var currenciesSignes: [String] {
        return currencies.compactMap { $0.rawValue }
    }
    
    func add(operation: Operation) {
        MainData.source.add(operation: operation)
    }
    func emojiFor(category: String) -> String {
        return MainData.settings.emojiForCategory[category] ?? DefaultEmoji.category
    }
    func emojiFor(contact: String) -> String {
        return MainData.settings.emojiForContact[contact] ?? DefaultEmoji.contact
    }
    
    
}

//
//  SettingsEditingPresenter.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 02/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

class SettingEditingPresenter {
    
    private let settingPresenter = SettingsPresenter.shared
    
    var outcomeCategories: [SettingsEntity] {
        get { return settingPresenter.outcomeCategories }
        set { settingPresenter.outcomeCategories = newValue }
    }
    
    var incomeCategories: [SettingsEntity] {
        get { return settingPresenter.incomeCategories }
        set { settingPresenter.incomeCategories = newValue }
    }
    
    var contacts: [SettingsEntity] {
        get { return settingPresenter.contacts }
        set { settingPresenter.contacts = newValue }
    }
    
    var accounts: [SettingsEntity] {
        get { return settingPresenter.accounts }
        set { settingPresenter.accounts = newValue }
    }
    
    var currencies: [CurrencySettingsEntity] {
        get { return settingPresenter.currencies }
        set { settingPresenter.currencies = newValue }
    }
    
    private(set) var operationsCountWithOutcomeCategories = [String: Int]()
    private(set) var operationsCountWithIncomeCategories = [String: Int]()
    private(set) var operationsCountWithContacts = [String: Int]()
    private(set) var operationsCountWithAccounts = [String: Int]()
    private(set) var operationsCountWithCurrencies = [Currency: Int]()
    
    func syncronize() {
        settingPresenter.syncronize()
    }
    
    init() {
        outcomeCategories.forEach { self.operationsCountWithOutcomeCategories[$0.name] = 0 }
        incomeCategories.forEach { self.operationsCountWithIncomeCategories[$0.name] = 0 }
        contacts.forEach { self.operationsCountWithContacts[$0.name] = 0 }
        accounts.forEach { self.operationsCountWithAccounts[$0.name] = 0 }
        outcomeCategories.forEach { self.operationsCountWithOutcomeCategories[$0.name] = 0 }
        
        let operations = MainData.source.operations
        for operation in operations {
            operationsCountWithCurrencies.incrementByOne(key: operation.currency)
            operationsCountWithAccounts.incrementByOne(key: operation.account)
            
            if let flowOp = operation as? FlowOperation {
                if flowOp.value < 0 {
                    operationsCountWithOutcomeCategories.incrementByOne(key: flowOp.category)
                } else {
                    operationsCountWithIncomeCategories.incrementByOne(key: flowOp.category)
                }
            } else if let debtOp = operation as? DebtOperation {
                operationsCountWithContacts.incrementByOne(key: debtOp.contact)
            }
        }
    }
    
    func replaceIncomeCategoryInOperations(currentCategory: String, newCategory: String, syncronize: Bool = false) {
        let operations = MainData.source.operations
        for operation in operations {
            if let flowOp = operation as? FlowOperation,
                flowOp.value >= 0,
                flowOp.category == currentCategory {
                edit(operation: operation, categoryOrContact: newCategory)
            }
        }
        if syncronize { MainData.source.save() }
    }
    
    func replaceOutcomeCategoryInOperations(currentCategory: String, newCategory: String, syncronize: Bool = false) {
        let operations = MainData.source.operations
        for operation in operations {
            if let flowOp = operation as? FlowOperation,
                flowOp.value < 0,
                flowOp.category == currentCategory {
                edit(operation: operation, categoryOrContact: newCategory)
            }
        }
        if syncronize { MainData.source.save() }
    }
    
    func replaceAccountInOperations(currentAccount: String, newAccount: String, syncronize: Bool = false) {
        let operations = MainData.source.operations
        for operation in operations {
            if operation.account == currentAccount {
                edit(operation: operation, account: newAccount)
            }
        }
        if syncronize { MainData.source.save() }
    }
    
    func replaceContactInOperations(currentContact: String, newContact: String, syncronize: Bool = false) {
        let operations = MainData.source.operations
        for operation in operations {
            if let debtOp = operation as? DebtOperation, debtOp.contact == currentContact {
                edit(operation: operation, categoryOrContact: newContact)
            }
        }
        if syncronize { MainData.source.save() }
    }
    
    private func edit(operation: Operation, date: Date? = nil, value: Double? = nil, currency: Currency? = nil, categoryOrContact: String? = nil, account: String? = nil, comment: String? = "unedited comment") {
        var resultComment = comment
        if comment == "unedited comment" {
            resultComment = ((operation as? FlowOperation)?.comment ?? (operation as? DebtOperation)?.comment)
        }
        MainData.source.editOperation(
            with: operation.id,
            date: date ?? operation.date,
            value: value ?? operation.value,
            currency: currency ?? operation.currency,
            categoryOrContact: categoryOrContact ?? ((operation as? FlowOperation)?.category ?? (operation as? DebtOperation)?.contact)!,
            account: account ?? operation.account,
            comment: resultComment
        )
    }
    
}

private extension Dictionary where Key == String, Value == Int {
    mutating func incrementByOne(key: String) {
        if self[key] != nil {
            self[key]! += 1
        } else {
            self[key] = 1
        }
    }
}
private extension Dictionary where Key == Currency, Value == Int {
    mutating func incrementByOne(key: Currency) {
        if self[key] != nil {
            self[key]! += 1
        } else {
            self[key] = 1
        }
    }
}

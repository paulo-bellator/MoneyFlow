//
//  SettingsPresenter.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 08/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

struct DefaultEmoji {
    static let category = "❓"
    static let contact = "❓"
}

class SettingsPresenter {
    
    static let shared = SettingsPresenter()
    
    var outcomeCategories: [SettingsEntity] {
        get { return MainData.settings.outcomeCategories }
        set { MainData.settings.set(outcomeCategories: newValue) }
    }
    var enabledOutcomeCategories: [String] {
        return outcomeCategories.compactMap { $0.enable ? $0.name : nil }
    }
    
    var incomeCategories: [SettingsEntity] {
        get { return MainData.settings.incomeCategories }
        set { MainData.settings.set(incomeCategories: newValue) }
    }
    var enabledIncomeCategories: [String] {
        return incomeCategories.compactMap { $0.enable ? $0.name : nil }
    }
    
    var contacts: [SettingsEntity] {
        get { return MainData.settings.contacts }
        set { MainData.settings.set(contacts: newValue) }
    }
    var enabledContacts: [String] {
        return contacts.compactMap { $0.enable ? $0.name : nil }
    }
    
    var accounts: [SettingsEntity] {
        get { return MainData.settings.accounts }
        set { MainData.settings.set(accounts: newValue) }
    }
    var enabledAccounts: [String] {
        return accounts.compactMap { $0.enable ? $0.name : nil }
    }
    
    var currencies: [CurrencySettingsEntity] {
        get { return MainData.settings.currencies }
        set { MainData.settings.set(currencies: newValue) }
    }
    var enabledCurrencies: [Currency] {
        return currencies.compactMap { $0.enable ? $0.currency : nil }
    }
    
    var enabledCurrenciesSignes: [String] {
        return enabledCurrencies.compactMap { $0.rawValue }
    }
    
    func emojiFor(category: String) -> String {
        return MainData.settings.emojiForCategory[category] ?? DefaultEmoji.category
    }
    func emojiFor(contact: String) -> String {
        return MainData.settings.emojiForContact[contact] ?? DefaultEmoji.contact
    }
    func set(emoji: String?, forCategory category: String) {
        MainData.settings.set(emoji: emoji, forCategory: category)
    }
    func set(emoji: String?, forContact contact: String) {
        MainData.settings.set(emoji: emoji, forContact: contact)
    }
    func syncronize() { MainData.settings.save() }
    
    var allEnabledCategoriesSorted: [String] {
        let categories = Array(Set(enabledOutcomeCategories + enabledIncomeCategories))
        var categoriesFrequency = Array(repeating: 0, count: categories.count)
        
        for op in MainData.source.operations.filter({ $0 is FlowOperation }) as! [FlowOperation] {
            if let index = categories.firstIndex(of: op.category) {
                categoriesFrequency[index] += 1
            }
        }
        return categories.sorted { op1, op2 in
            let indexOp1 = categories.firstIndex(of: op1)!
            let indexOp2 = categories.firstIndex(of: op2)!
            return categoriesFrequency[indexOp1] > categoriesFrequency[indexOp2]
        }
    }
    
    var enabledContactsSorted: [String] {
        let contacts = self.enabledContacts
        var contactsFrequency = Array(repeating: 0, count: contacts.count)
        
        for op in MainData.source.operations.filter({ $0 is DebtOperation }) as! [DebtOperation] {
            if let index = contacts.firstIndex(of: op.contact) {
                contactsFrequency[index] += 1
            }
        }
        return contacts.sorted { op1, op2 in
            let indexOp1 = contacts.firstIndex(of: op1)!
            let indexOp2 = contacts.firstIndex(of: op2)!
            return contactsFrequency[indexOp1] > contactsFrequency[indexOp2]
        }
    }
    
    var enabledAccountsSorted: [String] {
        let accounts = self.enabledAccounts
        var accountsFrequency = Array(repeating: 0, count: accounts.count)
        
        for op in MainData.source.operations {
            if let index = accounts.firstIndex(of: op.account) {
                accountsFrequency[index] += 1
            }
        }
        return accounts.sorted { op1, op2 in
            let indexOp1 = accounts.firstIndex(of: op1)!
            let indexOp2 = accounts.firstIndex(of: op2)!
            return accountsFrequency[indexOp1] > accountsFrequency[indexOp2]
        }
    }
    
    var enabledCurrenciesSorted: [Currency] {
        let currencies = self.enabledCurrencies
        var currenciesFrequency = Array(repeating: 0, count: currencies.count)
        
        for op in MainData.source.operations {
            if let index = currencies.firstIndex(of: op.currency) {
                currenciesFrequency[index] += 1
            }
        }
        return currencies.sorted { op1, op2 in
            let indexOp1 = currencies.firstIndex(of: op1)!
            let indexOp2 = currencies.firstIndex(of: op2)!
            return currenciesFrequency[indexOp1] > currenciesFrequency[indexOp2]
        }
    }
    
    var enabledCurrenciesSignesSorted: [String] {
        return enabledCurrenciesSorted.compactMap { $0.rawValue }
    }
    
    private init() {}
    
}

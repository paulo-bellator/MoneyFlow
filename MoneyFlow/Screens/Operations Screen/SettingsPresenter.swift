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
    
    private let defaultEmojiForCategory = "❓"
    private let defaultEmojiForContact = "❓"
    
    var outcomeCategories = MainData.settings.outcomeCategories { didSet { MainData.settings.set(outcomeCategories: outcomeCategories) } }
    var incomeCategories = MainData.settings.incomeCategories { didSet { MainData.settings.set(incomeCategories: incomeCategories) } }
    var allCategories: [String] {
        let categories = Array(Set(outcomeCategories + incomeCategories))
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
    var contacts = MainData.settings.contacts { didSet { MainData.settings.set(contacts: contacts) } }
    var accounts = MainData.settings.accounts { didSet { MainData.settings.set(accounts: accounts) } }
    var currencies = MainData.settings.currencies { didSet { MainData.settings.set(currencies: currencies) } }
    var currenciesSignes: [String] {
        return currencies.compactMap { $0.rawValue }
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
    
    private init() {}
    
}

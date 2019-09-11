//
//  DefaultSettingsDataSource.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 08/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation


class DefaultSettingsDataSource: SettingsDataSource {
    
    static let shared = DefaultSettingsDataSource()
    
    var outcomeCategories: [String] { didSet { thereAreUnsavedChanges = true } }
    var incomeCategories: [String] { didSet { thereAreUnsavedChanges = true } }
    var contacts: [String] { didSet { thereAreUnsavedChanges = true } }
    var accounts: [String] { didSet { thereAreUnsavedChanges = true } }
    var currencies: [Currency] { didSet { thereAreUnsavedChanges = true } }
    
    var emojiForCategory: [String: String] { didSet { thereAreUnsavedChanges = true } }
    var emojiForContact: [String: String] { didSet { thereAreUnsavedChanges = true } }

    private let defaults = UserDefaults()
    private var thereAreUnsavedChanges = false
    
    func set(outcomeCategories: [String]) {
        self.outcomeCategories = outcomeCategories
    }
    func set(incomeCategories: [String]) {
        self.incomeCategories = incomeCategories
    }
    func set(contacts: [String]) {
        self.contacts = contacts
    }
    func set(accounts: [String]) {
        self.accounts = accounts
    }
    func set(currencies: [Currency]) {
        self.currencies = currencies
    }
    func set(emoji: String?, forCategory category: String) {
        emojiForCategory[category] = emoji
    }
    func set(emoji: String?, forContact contact: String) {
        emojiForContact[contact] = emoji
    }
    
    func save() {
        if thereAreUnsavedChanges {
            print("\nsaved settings \n")
            
            defaults.set(emojiForCategory, forKey: UserDefaultsKeys.emojiForCategory)
            defaults.set(emojiForContact, forKey: UserDefaultsKeys.emojiForContacts)
            
            defaults.set(outcomeCategories, forKey: UserDefaultsKeys.outcomeCategories)
            defaults.set(incomeCategories, forKey: UserDefaultsKeys.incomeCategories)
            defaults.set(contacts, forKey: UserDefaultsKeys.contacts)
            defaults.set(accounts, forKey: UserDefaultsKeys.accounts)
            if let encodedCurrencies = try? JSONEncoder().encode(currencies) {
                defaults.set(encodedCurrencies, forKey: UserDefaultsKeys.currencies)
            }
            thereAreUnsavedChanges = false
        } else {
            print("not saved: Settings are actual")
        }
    }
    
    private init() {
        emojiForCategory = defaults.object(forKey: UserDefaultsKeys.emojiForCategory) as? [String: String] ?? [:]
        emojiForContact = defaults.object(forKey: UserDefaultsKeys.emojiForContacts) as? [String: String] ?? [:]
        
        outcomeCategories = defaults.object(forKey: UserDefaultsKeys.outcomeCategories) as? [String] ?? []
        incomeCategories = defaults.object(forKey: UserDefaultsKeys.incomeCategories) as? [String] ?? []
        contacts = defaults.object(forKey: UserDefaultsKeys.contacts) as? [String] ?? []
        accounts = defaults.object(forKey: UserDefaultsKeys.accounts) as? [String] ?? []
        if let decodedCurrencies = defaults.data(forKey: UserDefaultsKeys.currencies) {
            currencies = (try? JSONDecoder().decode([Currency].self, from: decodedCurrencies)) ?? []
        } else {
            currencies = Currency.all
        }
        fillWithPlaceHoldersIfNeeded()
        thereAreUnsavedChanges = false
    }
    
}

extension DefaultSettingsDataSource {
    private struct UserDefaultsKeys {
        static let outcomeCategories = "outcomeCategories"
        static let incomeCategories = "incomeCategories"
        static let contacts = "contacts"
        static let accounts = "accounts"
        static let currencies = "currencies"
        static let emojiForCategory = "emojiForCategory"
        static let emojiForContacts = "emojiForContacts"
    }
}

private extension DefaultSettingsDataSource {
    
    private func fillWithPlaceHoldersIfNeeded() {
        if outcomeCategories.isEmpty { outcomeCategories = placeHolderOutcomeCategories }
        if incomeCategories.isEmpty { incomeCategories = placeHolderIncomeCategories }
        if contacts.isEmpty { contacts = placeHolderContacts }
        if accounts.isEmpty { accounts = placeHolderAccounts }
        if currencies.isEmpty { currencies = placeHolderCurrencies }
        if emojiForCategory.isEmpty { emojiForCategory = placeHolderEmojiForCategories }
        if emojiForContact.isEmpty { emojiForContact = placeHolderEmojiForContacts }
    }
    
    private var placeHolderCurrencies: [Currency] {
        return Currency.all
    }
    private var placeHolderOutcomeCategories: [String] {
        return ["Продукты", "Развлечения", "Здоровье", "Проезд", "Связь и интернет", "Прочее"]
    }
    private var placeHolderIncomeCategories: [String] {
        return ["PPP", "Ситимобил", "Проценты и кешбек", "Прочее"]
    }
    private var placeHolderContacts: [String] {
        return ["ООО МояРабота", "Вася", "Петя", "Тигран"]
    }
    private var placeHolderAccounts: [String] {
        return ["Наличные", "Сбербанк МСК", "Альфа", "Хоум Кредит", "Сбербанк РНД"]
    }
    
    private var placeHolderEmojiForCategories: [String: String] {
        return ["Продукты": "🥦", "Развлечения": "🎮", "Здоровье": "💊", "Проезд": "🚎", "Связь и интернет": "📡", "PPP" : "🃏", "Ситимобил": "🚕", "Проценты и кешбек": "💸", "Прочее": "🤑"]
    }
    private var placeHolderEmojiForContacts: [String: String] {
        return ["ООО МояРабота": "🏢", "Вася": "👨‍🍳", "Петя": "🤵", "Тигран": "👳🏻‍♂️"]
    }
}


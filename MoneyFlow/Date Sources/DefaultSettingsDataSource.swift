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
    
    var categories: [String] { didSet { thereAreUnsavedChanges = true } }
    var contacts: [String] { didSet { thereAreUnsavedChanges = true } }
    var accounts: [String] { didSet { thereAreUnsavedChanges = true } }
    var currencies: [Currency] { didSet { thereAreUnsavedChanges = true } }
    
    var emojiForCategory: [String: String] { didSet { thereAreUnsavedChanges = true } }
    var emojiForContact: [String: String] { didSet { thereAreUnsavedChanges = true } }

    private let defaults = UserDefaults()
    private var thereAreUnsavedChanges = false
    
    func set(categories: [String]) {
        self.categories = categories
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
            
            defaults.set(categories, forKey: UserDefaultsKeys.categories)
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
        
        categories = defaults.object(forKey: UserDefaultsKeys.categories) as? [String] ?? []
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
        static let categories = "categories"
        static let contacts = "contacts"
        static let accounts = "accounts"
        static let currencies = "currencies"
        static let emojiForCategory = "emojiForCategory"
        static let emojiForContacts = "emojiForContacts"
    }
}

private extension DefaultSettingsDataSource {
    
    private func fillWithPlaceHoldersIfNeeded() {
        if categories.isEmpty { categories = placeHolderCategories }
        if contacts.isEmpty { contacts = placeHolderContacts }
        if accounts.isEmpty { accounts = placeHolderAccounts }
        if currencies.isEmpty { currencies = placeHolderCurrencies }
        if emojiForCategory.isEmpty { emojiForCategory = placeHolderEmojiForCategories }
        if emojiForContact.isEmpty { emojiForContact = placeHolderEmojiForContacts }
    }
    
    private var placeHolderCurrencies: [Currency] {
        return Currency.all
    }
    private var placeHolderCategories: [String] {
        return ["Продукты", "Развлечения", "Здоровье", "Проезд", "Связь и интернет"]
    }
    private var placeHolderContacts: [String] {
        return ["ООО МояРабота", "Вася", "Петя", "Тигран"]
    }
    private var placeHolderAccounts: [String] {
        return ["Наличные", "Сбербанк МСК", "Альфа", "Хоум Кредит", "Сбербанк РНД"]
    }
    
    private var placeHolderEmojiForCategories: [String: String] {
        return ["Продукты": "🥦", "Развлечения": "🎮", "Здоровье": "💊", "Проезд": "🚎", "Связь и интернет": "📡"]
    }
    private var placeHolderEmojiForContacts: [String: String] {
        return ["ООО МояРабота": "🏢", "Вася": "👨‍🍳", "Петя": "🤵", "Тигран": "👳🏻‍♂️"]
    }
}


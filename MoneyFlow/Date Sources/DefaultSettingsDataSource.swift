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
    
    var outcomeCategories = [String]() { didSet { thereAreUnsavedChanges = true } }
    var incomeCategories = [String]() { didSet { thereAreUnsavedChanges = true } }
    var contacts = [String]() { didSet { thereAreUnsavedChanges = true } }
    var accounts = [String]() { didSet { thereAreUnsavedChanges = true } }
    var currencies = [Currency]() { didSet { thereAreUnsavedChanges = true } }
    
    var emojiForCategory = [String: String]() { didSet { thereAreUnsavedChanges = true } }
    var emojiForContact = [String: String]() { didSet { thereAreUnsavedChanges = true } }

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
            
            if let data = try? JSONEncoder().encode(self.settings) {
                defaults.set(data, forKey: UserDefaultsKeys.settings)
            }
            thereAreUnsavedChanges = false
        } else {
            print("not saved: Settings are actual")
        }
    }
    
    private init() {
        if let data = defaults.data(forKey: UserDefaultsKeys.settings) {
            if let settings = (try? JSONDecoder().decode(Settings.self, from: data)) {
                self.settings = settings
            }
        }
        if currencies.isEmpty { currencies = Currency.all }
        
        fillWithPlaceHoldersIfNeeded()
        thereAreUnsavedChanges = false
    }
    
    
}

extension DefaultSettingsDataSource {
    private struct UserDefaultsKeys {
        static let settings = "settings"
    }
    
    private struct Settings: Codable {
        var uploadDate: Date = Date()
        var uploadDateFormatted = Date().formattedDescription
        var outcomeCategories: [String]
        var incomeCategories: [String]
        var contacts: [String]
        var accounts: [String]
        var currencies: [Currency]
        var emojiForCategory: [String: String]
        var emojiForContact: [String: String]
    }
    
    private var settings: Settings {
        get {
            return Settings(
                outcomeCategories: self.outcomeCategories,
                incomeCategories: self.incomeCategories,
                contacts: self.contacts,
                accounts: self.accounts,
                currencies: self.currencies,
                emojiForCategory: self.emojiForCategory,
                emojiForContact: self.emojiForContact)
        }
        set {
            self.outcomeCategories = newValue.outcomeCategories
            self.incomeCategories = newValue.incomeCategories
            self.contacts = newValue.contacts
            self.accounts = newValue.accounts
            self.currencies = newValue.currencies
            self.emojiForCategory = newValue.emojiForCategory
            self.emojiForContact = newValue.emojiForContact
        }
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


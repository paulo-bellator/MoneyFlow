//
//  CombinedSettingsDataSource.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 02/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation
import Firebase

class CombinedSettingDataSource: CloudSettingsDataSource {
    
    static let shared = CombinedSettingDataSource()
    
    weak var delegate: CloudSettingsDataSourceDelegate?
    private let storageRef = Storage.storage().reference()
    private let defaults = UserDefaults()
    
    private var thereAreUnsavedChanges = false {
        didSet {
            if oldValue == false && thereAreUnsavedChanges == true {
                isSyncronized = false
            }
        }
    }
    private var isSyncronized = true
    private(set) var isDownloadComplete = false
    private var activeTasks = [CancelableStorageTask]()
    
    private func downloadCompleted() {
        isDownloadComplete = true
        if GlobalConstants.CloudDataSource.isFirstLoad {
            GlobalConstants.CloudDataSource.firstLoadComplete()
        }

//        let areAllEmpty = outcomeCategories.isEmpty
//            && incomeCategories.isEmpty
//            && contacts.isEmpty
//            && accounts.isEmpty
//        areAllEmpty ? getDataFromDefaults() : save()
    }
    
    
    // MARK: Public API
    
    var outcomeCategories = [SettingsEntity]() { didSet { thereAreUnsavedChanges = true } }
    var incomeCategories = [SettingsEntity]() { didSet { thereAreUnsavedChanges = true } }
    var contacts = [SettingsEntity]() { didSet { thereAreUnsavedChanges = true } }
    var accounts = [SettingsEntity]() { didSet { thereAreUnsavedChanges = true } }
    var currencies = [CurrencySettingsEntity]() { didSet { thereAreUnsavedChanges = true } }
    
    var emojiForCategory = [String: String]() { didSet { thereAreUnsavedChanges = true } }
    var emojiForContact = [String: String]() { didSet { thereAreUnsavedChanges = true } }
    
    func set(outcomeCategories: [SettingsEntity]) {
        self.outcomeCategories = outcomeCategories
    }
    func set(incomeCategories: [SettingsEntity]) {
        self.incomeCategories = incomeCategories
    }
    func set(contacts: [SettingsEntity]) {
        self.contacts = contacts
    }
    func set(accounts: [SettingsEntity]) {
        self.accounts = accounts
    }
    func set(currencies: [CurrencySettingsEntity]) {
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
            saveDataToDefaults()
        }
        if !isSyncronized {
            saveDataToStorage()
        }
    }
    
    func updateData() {
        getDataFromStorage()
    }
    
    func cancelLoading() {
        activeTasks.cancelAndRemoveAll()
    }
    
    // MARK: Initialization
    
    // call makes nothing but create static instance of this class
    func configure() {}
    
    private init() {
        // (isDownloadComplete = true) calls getDataFromDefaults()
        if GlobalConstants.CloudDataSource.isFirstLoad { getDataFromStorage() }
        else {
            getDataFromDefaults()
            downloadCompleted()
        }
        print("combined settings init")
    }
    
    // MARK: Getting and pushing data
    
    private func saveDataToDefaults() {
        print("combined settings saved to defaults")
        if let data = try? JSONEncoder().encode(self.settings) {
            defaults.set(data, forKey: UserDefaultsKeys.settings)
        }
        thereAreUnsavedChanges = false
    }
    
    private func saveDataToStorage() {
        print("combined settings saved to storage")
        activeTasks.cancelAndRemoveAll()
        
        let encoder = JSONEncoder()
        let settingsRef = storageRef.child(Path.settings)
        let metadata = StorageMetadata()
        metadata.contentType = "application/json"
        
        if let data = try? encoder.encode(self.settings) {
            let uploadTask = settingsRef.putData(data, metadata: metadata) { (metadata, error) in
                self.delegate?.settingsUploadComplete(with: error)
                self.isSyncronized = true
            }
            activeTasks.append(uploadTask)
            uploadTask.observe(.failure) { _ in
                self.isSyncronized = false
            }
        }
    }
    
    private func getDataFromDefaults() {
        print("combined settings got from defaults")
        if let data = defaults.data(forKey: UserDefaultsKeys.settings) {
            if let settings = (try? JSONDecoder().decode(Settings.self, from: data)) {
                self.settings = settings
            }
        }
        if currencies.isEmpty { currencies = Currency.all.map { CurrencySettingsEntity(currency: $0) } }
        thereAreUnsavedChanges = false
        isSyncronized = false
    }
    
    private func getDataFromStorage() {
        print("combined settings got from storage")
        activeTasks.cancelAndRemoveAll()
        isDownloadComplete = false
        
        let decoder = JSONDecoder()
        let settingsRef = storageRef.child(Path.settings)
        
        // Download in memory with a maximum allowed size of 1MB (5 * 1024 * 1024 bytes)
        let downloadTask = settingsRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if error == nil || error?.localizedDescription == Path.doesNotExistError {
                if let data = data, let settings = (try? decoder.decode(Settings.self, from: data))  {
                    self.settings = settings
                } else {
                    self.settings = Settings.defaultInit
                }
                if self.settings.currencies.isEmpty { self.settings = Settings.defaultInit }
                self.isSyncronized = true
                self.downloadCompleted()
                self.saveDataToDefaults()
                self.delegate?.settingsDownloadComplete(with: nil)
            } else {
                self.delegate?.settingsDownloadComplete(with: error)
            }
        }
        activeTasks.append(downloadTask)
    }
}

// MARK: Supporting additionals

extension CombinedSettingDataSource {
    private struct Path {
        static let settingsFile = "settings.json"
        static var userFolder: String {
            //            return UIDevice.current.identifierForVendor!.uuidString
            return Auth.auth().currentUser!.email!
        }
        static var settings: String {
            return "\(userFolder)/\(settingsFile)"
        }
        static var doesNotExistError: String {
            return "Object " + settings + " does not exist."
        }
    }
    private struct Settings: Codable {
       var uploadDate: Date = Date()
        var uploadDateFormatted = Date().formattedDescription
        var outcomeCategories: [SettingsEntity]
        var incomeCategories: [SettingsEntity]
        var contacts: [SettingsEntity]
        var accounts: [SettingsEntity]
        var currencies: [CurrencySettingsEntity]
        var emojiForCategory: [String: String]
        var emojiForContact: [String: String]
        
        static var defaultInit: Settings {
            let currencies = Currency.all.map { CurrencySettingsEntity(currency: $0) }
            return Settings(
                outcomeCategories: [SettingsEntity(name: "Категория #1")],
                incomeCategories: [SettingsEntity(name: "Инициализирующая категория")],
                contacts: [SettingsEntity(name: "Контакт #1")],
                accounts: [SettingsEntity(name: "Наличные")],
                currencies: currencies,
                emojiForCategory: [:],
                emojiForContact: [:])
        }
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
    
    private struct UserDefaultsKeys {
        static let settings = "settings"
    }
}

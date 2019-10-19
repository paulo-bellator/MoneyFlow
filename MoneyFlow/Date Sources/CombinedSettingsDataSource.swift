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
        let areAllEmpty = outcomeCategories.isEmpty
            && incomeCategories.isEmpty
            && contacts.isEmpty
            && accounts.isEmpty
        areAllEmpty ? getDataFromDefaults() : save()
    }
    
    
    // MARK: Public API
    
    var outcomeCategories = [String]() { didSet { thereAreUnsavedChanges = true } }
    var incomeCategories = [String]() { didSet { thereAreUnsavedChanges = true } }
    var contacts = [String](){ didSet { thereAreUnsavedChanges = true } }
    var accounts = [String]() { didSet { thereAreUnsavedChanges = true } }
    var currencies = [Currency]() { didSet { thereAreUnsavedChanges = true } }
    
    var emojiForCategory = [String: String]() { didSet { thereAreUnsavedChanges = true } }
    var emojiForContact = [String: String]() { didSet { thereAreUnsavedChanges = true } }
    
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
        activeTasks.forEach { $0.cancel() }
        activeTasks.removeAll()
    }
    
    // MARK: Initialization
    
    // call makes nothing but create static instance of this class
    func configure() {}
    
    private init() {
        // (isDownloadComplete = true) calls getDataFromDefaults()
        if AppDelegate.isThisNotFirstLaunch { downloadCompleted() }
        else {
            getDataFromStorage()
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
        activeTasks.forEach { $0.cancel() }
        activeTasks.removeAll()
        
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
        if currencies.isEmpty { currencies = Currency.all }
        thereAreUnsavedChanges = false
        isSyncronized = false
    }
    
    private func getDataFromStorage() {
        print("combined settings got from storage")
        activeTasks.forEach { $0.cancel() }
        activeTasks.removeAll()
        isDownloadComplete = false
        
        let decoder = JSONDecoder()
        let settingsRef = storageRef.child(Path.settings)
        
        // Download in memory with a maximum allowed size of 1MB (5 * 1024 * 1024 bytes)
        let downloadTask = settingsRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if error == nil {
                if let data = data {
                    if let settings = (try? decoder.decode(Settings.self, from: data)) { self.settings = settings }
                }
                self.thereAreUnsavedChanges = true
                self.isSyncronized = true
                self.downloadCompleted()
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
        static var deviceFolder: String {
            return UIDevice.current.identifierForVendor!.uuidString
        }
        static var settings: String {
            return "\(deviceFolder)/\(settingsFile)"
        }
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
    
    private struct UserDefaultsKeys {
        static let settings = "settings"
    }
}

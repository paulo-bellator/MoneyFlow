//
//  FirebaseSettingsDataSource.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 12/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation
import Firebase

class FirebaseSettingsDataSource: CloudSettingsDataSource {
    
    static let shared = FirebaseSettingsDataSource()
    
    weak var delegate: CloudSettingsDataSourceDelegate?
    private let storageRef = Storage.storage().reference()
    private var thereAreUnsavedChanges = false
    private(set) var isDownloadComplete = false
    private var activeTasks = [CancelableStorageTask]()
    
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
            print("\nsaved\n")
            thereAreUnsavedChanges = false
            pushData()
        } else { print("not saved: Data is actual") }
    }
 
    func updateData() {
        getData()
    }
    
    func cancelLoading() {
        activeTasks.forEach { $0.cancel() }
        activeTasks.removeAll()
    }
    
    // call makes nothing but create static instance of this class
    func configure() {}
    
    private init() {
        print("settings init")
        getData()
    }
    
    private func pushData() {
        activeTasks.cancelAndRemoveAll()
        
        let encoder = JSONEncoder()
        let settingsRef = storageRef.child(Path.settings)
        let metadata = StorageMetadata()
        metadata.contentType = "application/json"
        
        if let data = try? encoder.encode(self.settings) {
            let uploadTask = settingsRef.putData(data, metadata: metadata) { (metadata, error) in
                self.delegate?.settingsUploadComplete(with: error)
            }
            activeTasks.append(uploadTask)
            uploadTask.observe(.failure) { _ in
                self.thereAreUnsavedChanges = true
            }
        }
    }
    
    private func getData() {
        activeTasks.cancelAndRemoveAll()
        isDownloadComplete = false
    
        let decoder = JSONDecoder()
        let settingsRef = storageRef.child(Path.settings)

        // Download in memory with a maximum allowed size of 1MB (5 * 1024 * 1024 bytes)
        let downloadTask = settingsRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if error == nil {
                if let data = data {
                    if let settings = (try? decoder.decode(Settings.self, from: data)) { self.settings = settings }
                }
                self.isDownloadComplete = true
                self.thereAreUnsavedChanges = false
            } else if error!.localizedDescription == Path.doesNotExistError {
                self.currencies = Currency.all.map { CurrencySettingsEntity(currency: $0) }
            }
            self.delegate?.settingsDownloadComplete(with: error)
        }
        activeTasks.append(downloadTask)
    }
}

extension FirebaseSettingsDataSource {
    private struct Path {
        static let settingsFile = "settings.json"
        static var deviceFolder: String {
            return UIDevice.current.identifierForVendor!.uuidString
        }
        static var settings: String {
            return "\(deviceFolder)/\(settingsFile)"
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




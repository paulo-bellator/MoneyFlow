//
//  DataSource.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

protocol OperationDataSource {
    var operations: [Operation] { get }
    func add(operation: Operation)
    func editOperation(with identifier: Int, date: Date, value: Double, currency: Currency, categoryOrContact: String, account: String, comment: String?)
    func removeOperation(with identifier: Int)
    func save()
}

protocol CloudOperationDataSource: OperationDataSource {
    var delegate: CloudDataSourceDelegate? { get set }
    var isDownloadComplete: Bool { get }
    func updateData()
    func cancelLoading()
    func configure()
}
protocol CloudDataSourceDelegate: class {
    var downloadProgress: Double { get set }
    var uploadProgress: Double { get set }
    func downloadComplete(with error: Error?)
    func uploadComplete(with error: Error?)
}

protocol SettingsDataSource {
    var outcomeCategories: [SettingsEntity] { get }
    var incomeCategories: [SettingsEntity] { get }
    var contacts: [SettingsEntity] { get set }
    var accounts: [SettingsEntity] { get }
    var currencies: [CurrencySettingsEntity] { get }
    var emojiForCategory: [String: String] { get }
    var emojiForContact: [String: String] { get }
    
    func set(outcomeCategories: [SettingsEntity])
    func set(incomeCategories: [SettingsEntity])
    func set(contacts: [SettingsEntity])
    func set(accounts: [SettingsEntity])
    func set(currencies: [CurrencySettingsEntity])
    func set(emoji: String?, forCategory category: String)
    func set(emoji: String?, forContact contact: String)
    func save()
}

protocol CloudSettingsDataSource: SettingsDataSource {
    var delegate: CloudSettingsDataSourceDelegate? { get set }
    var isDownloadComplete: Bool { get }
    func updateData()
    func cancelLoading()
    func configure()
}
protocol CloudSettingsDataSourceDelegate: class {
    func settingsDownloadComplete(with error: Error?)
    func settingsUploadComplete(with error: Error?)
}

class MainData {
//    static let source: OperationDataSource = CombinedDataSource.shared
//    static let settings: SettingsDataSource = CombinedSettingDataSource.shared
    static let source: OperationDataSource = DefaultDataSource.shared
    static let settings: SettingsDataSource = DefaultSettingsDataSource.shared
//    static var source: OperationDataSource = FirebaseDataSource.shared
//    static let settings: SettingsDataSource = FirebaseSettingsDataSource.shared
}


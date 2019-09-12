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
    func removeOperation(with identifier: Int)
    func save()
}

protocol CloudOperationDataSource: OperationDataSource {
    var delegate: CloudDataSourceDelegate? { get set }
    var isDownloadComplete: Bool { get }
    func updateData()
}
protocol CloudDataSourceDelegate: class {
    var downloadProgress: Double { get set }
    var uploadProgress: Double { get set }
    func downloadComplete(with error: Error?)
    func uploadComplete(with error: Error?)
}

protocol SettingsDataSource {
    var outcomeCategories: [String] { get }
    var incomeCategories: [String] { get }
    var contacts: [String] { get set }
    var accounts: [String] { get }
    var currencies: [Currency] { get }
    var emojiForCategory: [String: String] { get }
    var emojiForContact: [String: String] { get }
    
    func set(outcomeCategories: [String])
    func set(incomeCategories: [String])
    func set(contacts: [String])
    func set(accounts: [String])
    func set(currencies: [Currency])
    func set(emoji: String?, forCategory category: String)
    func set(emoji: String?, forContact contact: String)
    func save()
}

protocol CloudSettingsDataSource: SettingsDataSource {
    var delegate: CloudSettingsDataSourceDelegate? { get set }
    var isDownloadComplete: Bool { get }
    func updateData()
}
protocol CloudSettingsDataSourceDelegate: class {
    func settingsDownloadComplete(with error: Error?)
    func settingsUploadComplete(with error: Error?)
}

class MainData {
    static let source: OperationDataSource = DefaultDataSource.shared
//    static var source: CloudOperationDataSource = FirebaseDataSource.shared
    static let settings: SettingsDataSource = DefaultSettingsDataSource.shared
}


//
//  CombinedDataSource.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation
import Firebase

class CombinedDataSource: CloudOperationDataSource {
    
    static let shared = CombinedDataSource()
    
    private var cloudGenerator: CloudIDGenerator?
    private(set) var operations: [Operation] = []
    weak var delegate: CloudDataSourceDelegate?
    
    private let storageRef = Storage.storage().reference()
    private let defaults = UserDefaults()
    
    private var changesCounter = 0
    private var thereAreUnsavedChanges = false
    private(set) var isDownloadComplete = false
    private var activeTasks = [CancelableStorageTask]()
    
    private func downloadCompleted() {
        isDownloadComplete = true
        if GlobalConstants.CloudDataSource.isFirstLoad {
            GlobalConstants.CloudDataSource.firstLoadComplete()
        }
//        // emptiness means no data in cloud storage, so get from defaults
//        // if not empty, we trying to save data (in defaults)
//        // in save(), we save only if we get fresh data from cloud storage
//        operations.isEmpty ? getDataFromDefaults() : save()
    }
    
    // MARK: Public API
    
    func add(operation: Operation) {
        if !operations.contains(where: { $0.id == operation.id }) {
            operations.append(operation)
            thereAreUnsavedChanges = true
            changesCounter += 1
        }
    }

    /// - parameter specialField: This is category, contact or destinationAccount for appropriate operation's type
    func editOperation(with identifier: Int, date: Date, value: Double, currency: Currency, account: String, comment: String? = nil, specialField: String) {
        for operation in operations {
            if operation.id == identifier {
                if let flowOp = operation as? FlowOperation {
                    flowOp.date = date
                    flowOp.value = value
                    flowOp.currency = currency
                    flowOp.category = specialField
                    flowOp.account = account
                    flowOp.comment = comment
                } else if let debtOp = operation as? DebtOperation {
                    debtOp.date = date
                    debtOp.value = value
                    debtOp.currency = currency
                    debtOp.contact = specialField
                    debtOp.account = account
                    debtOp.comment = comment
                } else if let transferOp = operation as? TransferOperation {
                    transferOp.date = date
                    transferOp.value = value
                    transferOp.currency = currency
                    transferOp.account = account
                    transferOp.destinationAccount = specialField
                }
                thereAreUnsavedChanges = true
                changesCounter += 1
            }
        }
    }
    func removeOperation(with identifier: Int) {
        let previosCount = operations.count
        operations = operations.filter { $0.id != identifier }
        if previosCount != operations.count {
            thereAreUnsavedChanges = true
            changesCounter += 1
        }
    }
    
    func save() {
        if changesCounter >= Constants.changesValueToSyncronize {
            cloudGenerator?.save()
            saveDataToStorage()
        }
        if thereAreUnsavedChanges {
            saveDataToDefaults()
            defaults.set(changesCounter, forKey: UserDefaultsKeys.changesCounter)
        }
    }
    
    func saveToStorageForced() {
        cloudGenerator?.save()
        saveDataToStorage()
    }
    
    func updateData() {
        cloudGenerator?.updateData()
        getDataFromStorage()
    }
    
    func cancelLoading() {
        activeTasks.cancelAndRemoveAll()
        cloudGenerator?.cancelLoading()
    }
    
    // MARK: Initialization
    
    // call makes nothing but create static instance of this class
    func configure() {}
    
    private init() {
        changesCounter = defaults.integer(forKey: UserDefaultsKeys.changesCounter)
        
        // (isDownloadComplete = true) calls getDataFromDefaults()
        if GlobalConstants.CloudDataSource.isFirstLoad { getDataFromStorage() }
        else {
            getDataFromDefaults()
            downloadCompleted()
        }
        
        if let generator = MainGenerator.generator as? CloudIDGenerator {
            cloudGenerator = generator
        }
    }
    
    // MARK: Getting and pushing data
    
    private func saveDataToDefaults() {
        let encoder = JSONEncoder()
        let flowOperations = operations.filter { $0 is FlowOperation } as! [FlowOperation]
        let debtOperations = operations.filter { $0 is DebtOperation } as! [DebtOperation]
        let transferOperations = operations.filter { $0 is TransferOperation } as! [TransferOperation]
        let ops = Ops(flowOps: flowOperations, debtOps: debtOperations, transferOps: transferOperations)
        
        if let encoded = try? encoder.encode(ops) {
            defaults.set(encoded, forKey: UserDefaultsKeys.operations)
        }
        thereAreUnsavedChanges = false
    }
    
    private func saveDataToStorage() {
        activeTasks.cancelAndRemoveAll()
        
        let encoder = JSONEncoder()
        let operationsRef = storageRef.child(Path.operations)
        let metadata = StorageMetadata()
        metadata.contentType = "application/json"
        
        let flowOperations = operations.filter { $0 is FlowOperation } as! [FlowOperation]
        let debtOperations = operations.filter { $0 is DebtOperation } as! [DebtOperation]
        let transferOperations = operations.filter { $0 is TransferOperation } as! [TransferOperation]
        let ops = Ops(flowOps: flowOperations, debtOps: debtOperations, transferOps: transferOperations)
        
        if let data = try? encoder.encode(ops) {
            let uploadTask = operationsRef.putData(data, metadata: metadata) { (metadata, error) in
                if error == nil {
                    self.changesCounter = 0
                    self.defaults.set(self.changesCounter, forKey: UserDefaultsKeys.changesCounter)
                }
                self.delegate?.uploadComplete(with: error)
            }
            activeTasks.append(uploadTask)
//            uploadTask.observe(.failure) { _ in
//                self.thereAreUnsavedChanges = true
//            }
            uploadTask.observe(.progress) { snapshot in
                self.delegate?.uploadProgress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            }
        }
        
    }
    
    private func getDataFromDefaults() {
        let decoder = JSONDecoder()
        
        if let data = defaults.data(forKey: UserDefaultsKeys.operations) {
            if let ops = (try? decoder.decode(Ops.self, from: data)) {
                operations = ops.flowOps + ops.debtOps + ops.transferOps
            }
        }
        thereAreUnsavedChanges = false
    }
    
    private func getDataFromStorage() {
        activeTasks.cancelAndRemoveAll()
        isDownloadComplete = false
        
        let decoder = JSONDecoder()
        let operationsRef = storageRef.child(Path.operations)
        
        let downloadTask = operationsRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if error == nil || error?.localizedDescription == Path.doesNotExistError {
                if let data = data, let ops = (try? decoder.decode(Ops.self, from: data)) {
                    self.operations = ops.flowOps + ops.debtOps + ops.transferOps
                } else {
                    self.operations = []
                }
                self.changesCounter = 0
                self.downloadCompleted()
                self.saveDataToDefaults()
                self.delegate?.downloadComplete(with: nil)
            } else {
                self.delegate?.downloadComplete(with: error)
            }
            // TODO: handle errors 
            // if we have fresh data in cloud storage, and can't get it
            // due to some troubles (net connection etc), i get error and empty ops,
            // so i'll get not actual data from defaults and may be
            // resave it into storage, so i'll lose fresh data
            // need to fix it
        }
        activeTasks.append(downloadTask)
        downloadTask.observe(.progress) { snapshot in
            self.delegate?.downloadProgress =  Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
        }
    }
}


extension CombinedDataSource {
    private struct Path {
        static let operationsFile = "operations.json"
        
        static var userFolder: String {
//            return UIDevice.current.identifierForVendor!.uuidString
            return Auth.auth().currentUser!.email!
        }
        static var operations: String {
            return "\(userFolder)/\(operationsFile)"
        }
        static var doesNotExistError: String {
            return "Object " + operations + " does not exist."
        }
    }
    
    private struct UserDefaultsKeys {
        static let operations = "operations"
        static let changesCounter = "changesCounter"
    }
    
    private struct Constants {
        static let changesValueToSyncronize = 15
    }
    
    private struct Ops: Codable {
        var uploadDate: Date = Date()
        var uploadDateFormatted = Date().formattedDescription
        var flowOps: [FlowOperation]
        var debtOps: [DebtOperation]
        var transferOps: [TransferOperation]
    }
}


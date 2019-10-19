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
        // emptiness means no data in cloud storage, so get from defaults
        // if not empty, we trying to save data (in defaults)
        // in save(), we save only if we get fresh data from cloud storage
        operations.isEmpty ? getDataFromDefaults() : save()
    }
    
    // MARK: Public API
    
    func add(operation: Operation) {
        if !operations.contains(where: { $0.id == operation.id }) {
            operations.append(operation)
            thereAreUnsavedChanges = true
            changesCounter += 1
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
        cloudGenerator?.save()
        if changesCounter >= Constants.changesValueToSyncronize {
            saveDataToStorage()
        }
        if thereAreUnsavedChanges {
            saveDataToDefaults()
            defaults.set(changesCounter, forKey: UserDefaultsKeys.changesCounter)
        }
    }
    
    func updateData() {
        cloudGenerator?.updateData()
        getDataFromStorage()
    }
    
    func cancelLoading() {
        activeTasks.forEach { $0.cancel() }
        activeTasks.removeAll()
        cloudGenerator?.cancelLoading()
    }
    
    // MARK: Initialization
    
    // call makes nothing but create static instance of this class
    func configure() {}
    
    private init() {
        changesCounter = defaults.integer(forKey: UserDefaultsKeys.changesCounter)
        
        // (isDownloadComplete = true) calls getDataFromDefaults()
        if AppDelegate.isThisNotFirstLaunch { downloadCompleted() }
        else {
            getDataFromStorage()
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
        let ops = Ops(flowOps: flowOperations, debtOps: debtOperations)
        
        if let encoded = try? encoder.encode(ops) {
            defaults.set(encoded, forKey: UserDefaultsKeys.operations)
        }
        thereAreUnsavedChanges = false
    }
    
    private func saveDataToStorage() {
        activeTasks.forEach { $0.cancel() }
        activeTasks.removeAll()
        
        let encoder = JSONEncoder()
        let operationsRef = storageRef.child(Path.operations)
        let metadata = StorageMetadata()
        metadata.contentType = "application/json"
        
        let flowOperations = operations.filter { $0 is FlowOperation } as! [FlowOperation]
        let debtOperations = operations.filter { $0 is DebtOperation } as! [DebtOperation]
        let ops = Ops(flowOps: flowOperations, debtOps: debtOperations)
        
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
                operations = ops.flowOps + ops.debtOps
            }
        }
        thereAreUnsavedChanges = false
    }
    
    private func getDataFromStorage() {
        activeTasks.forEach { $0.cancel() }
        activeTasks.removeAll()
        isDownloadComplete = false
        
        let decoder = JSONDecoder()
        let operationsRef = storageRef.child(Path.operations)
        
        let downloadTask = operationsRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if error == nil {
                if let data = data {
                    if let ops = (try? decoder.decode(Ops.self, from: data)) {
                        self.operations = ops.flowOps + ops.debtOps
                        self.thereAreUnsavedChanges = true
                        self.changesCounter = 0
                    }
                }
                self.downloadCompleted()
            }
            // TODO: handle errors 
            // if we have fresh data in cloud storage, and can't get it
            // due to some troubles (net connection etc), i get error and empty ops,
            // so i'll get not actual data from defaults and may be
            // resave it into storage, so i'll lose fresh data
            // need to fix it
            self.delegate?.downloadComplete(with: error)
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
        
        static var deviceFolder: String {
            return UIDevice.current.identifierForVendor!.uuidString
        }
        static var operations: String {
            return "\(deviceFolder)/\(operationsFile)"
        }
    }
    
    private struct UserDefaultsKeys {
        static let operations = "operations"
        static let changesCounter = "changesCounter"
    }
    
    private struct Constants {
        static let changesValueToSyncronize = 5
    }
    
    private struct Ops: Codable {
        var uploadDate: Date = Date()
        var uploadDateFormatted = Date().formattedDescription
        var flowOps: [FlowOperation]
        var debtOps: [DebtOperation]
    }
}


//
//  FirebaseDataSource.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 12/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation
import Firebase

class FirebaseDataSource: CloudOperationDataSource {
    
    static let shared = FirebaseDataSource()
    
    private(set) var operations: [Operation] = []
    weak var delegate: CloudDataSourceDelegate?
    private let storageRef = Storage.storage().reference()
    private var thereAreUnsavedChanges = false
    private(set) var isDownloadComplete = false
    
    private var activeTasks = [CancelableStorageTask]()
    private var firstUploadIsComplete = false
    private var uploadProgress = 0.0 { didSet { delegate?.uploadProgress = uploadProgress } }
    private var uploadFlowOpsProgress = 0.0 { didSet { uploadProgress = (uploadFlowOpsProgress + uploadDebtOpsProgress)/2 } }
    private var uploadDebtOpsProgress = 0.0 { didSet { uploadProgress = (uploadFlowOpsProgress + uploadDebtOpsProgress)/2 } }
    
    private var firstDownloadIsComplete = false
    private var downloadProgress = 0.0 { didSet { delegate?.downloadProgress = downloadProgress } }
    private var downloadFlowOpsProgress = 0.0 { didSet { downloadProgress = (downloadFlowOpsProgress + downloadDebtOpsProgress)/2 } }
    private var downloadDebtOpsProgress = 0.0 { didSet { downloadProgress = (downloadFlowOpsProgress + downloadDebtOpsProgress)/2 } }
    
    
    private var flowOperations: [FlowOperation] = [] {
        didSet { if !flowOperations.isEmpty { operations += flowOperations } }
    }
    private var debtOperations: [DebtOperation] = [] {
        didSet { if !debtOperations.isEmpty { operations += debtOperations } }
    }
    
    
    func add(operation: Operation) {
        if !operations.contains(where: { $0.id == operation.id }) {
            operations.append(operation)
            thereAreUnsavedChanges = true
        }
    }
    func removeOperation(with identifier: Int) {
        let previosCount = operations.count
        operations = operations.filter { $0.id != identifier }
        if previosCount != operations.count { thereAreUnsavedChanges = true }
    }
    func save() {
        if thereAreUnsavedChanges {
            print("\nsaved\n")
            thereAreUnsavedChanges = false
            pushData()
        } else { print("not saved: Data is actual") }
    }
    func updateData() {
        operations = []
        getData()
    }
    
    private init() {
        getData()
    }
    
    private func pushData() {
        activeTasks.forEach { $0.cancel() }
        activeTasks.removeAll()
        uploadFlowOpsProgress = 0
        uploadDebtOpsProgress = 0
        firstUploadIsComplete = false
        
        let encoder = JSONEncoder()
        let flowOperationsRef = storageRef.child(Path.flowOperations)
        let debtOperationsRef = storageRef.child(Path.debtOperations)
        let metadata = StorageMetadata()
        metadata.contentType = "application/json"
        
        flowOperations = operations.filter { $0 is FlowOperation } as! [FlowOperation]
        debtOperations = operations.filter { $0 is DebtOperation } as! [DebtOperation]
        
        if let data = try? encoder.encode(flowOperations) {
            let flowTask = flowOperationsRef.putData(data, metadata: metadata) { (metadata, error) in
                if self.firstUploadIsComplete { self.delegate?.uploadComplete(with: error) }
                else { self.firstUploadIsComplete = true }
                
                guard metadata != nil else { return }
//                print("Downloaded data's size is \(metadata.size)")
            }
            activeTasks.append(flowTask)
            flowTask.observe(.failure) { _ in
                self.thereAreUnsavedChanges = true
            }
            flowTask.observe(.progress) { snapshot in
                self.uploadFlowOpsProgress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            }
            
        }
        if let data = try? encoder.encode(debtOperations) {
            let debtTask = debtOperationsRef.putData(data, metadata: metadata) { (metadata, error) in
                if self.firstUploadIsComplete { self.delegate?.uploadComplete(with: error) }
                else { self.firstUploadIsComplete = true }
                
                guard metadata != nil else { return }
//                print("Downloaded data's size is \(metadata.size)")
            }
            activeTasks.append(debtTask)
            debtTask.observe(.failure) { _ in
                self.thereAreUnsavedChanges = true
            }
            debtTask.observe(.progress) { snapshot in
                self.uploadDebtOpsProgress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            }
        }
    }
    
    private func getData() {
        activeTasks.forEach { $0.cancel() }
        activeTasks.removeAll()
        downloadFlowOpsProgress = 0
        downloadDebtOpsProgress = 0
        isDownloadComplete = false
        firstDownloadIsComplete = false
        
        let decoder = JSONDecoder()
        let flowOperationsRef = storageRef.child(Path.flowOperations)
        let debtOperationsRef = storageRef.child(Path.debtOperations)
        
        // Download in memory with a maximum allowed size of 1MB (5 * 1024 * 1024 bytes)
        let flowTask = flowOperationsRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if self.firstDownloadIsComplete {
                self.isDownloadComplete = true
                self.delegate?.downloadComplete(with: error)
            }
            else { self.firstDownloadIsComplete = true }
            
            if error != nil { /* print(error) */ }
            else {
                if let data = data {
                    self.flowOperations = (try? decoder.decode([FlowOperation].self, from: data)) ?? []
                }
            }
        }
        activeTasks.append(flowTask)
        flowTask.observe(.progress) { snapshot in
            self.downloadFlowOpsProgress =  Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
        }
        
        // Download in memory with a maximum allowed size of 1MB (5 * 1024 * 1024 bytes)
        let debtTask = debtOperationsRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if self.firstDownloadIsComplete {
                self.isDownloadComplete = true
                self.delegate?.downloadComplete(with: error)
            }
            else { self.firstDownloadIsComplete = true }
            
            if error != nil { /* print(error) */ }
            else {
                if let data = data {
                    self.debtOperations = (try? decoder.decode([DebtOperation].self, from: data)) ?? []
                }
            }
        }
        activeTasks.append(debtTask)
        debtTask.observe(.progress) { snapshot in
            self.downloadDebtOpsProgress =  Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
        }
        
       
    }
}

extension FirebaseDataSource {
    private struct Path {
        static let flowOperationsFile = "flow_operations.json"
        static let debtOperationsFile = "debt_operations.json"
        
        static var deviceFolder: String {
            return UIDevice.current.identifierForVendor!.uuidString
        }
        static var flowOperations: String {
            return "\(deviceFolder)/\(flowOperationsFile)"
        }
        static var debtOperations: String {
            return "\(deviceFolder)/\(debtOperationsFile)"
        }
    }
}

protocol CancelableStorageTask {
    func cancel()
}
extension StorageUploadTask: CancelableStorageTask {}
extension StorageDownloadTask: CancelableStorageTask {}


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
    
    private var cloudGenerator: CloudIDGenerator?
    private(set) var operations: [Operation] = []
    weak var delegate: CloudDataSourceDelegate?
    private let storageRef = Storage.storage().reference()
    private var thereAreUnsavedChanges = false
    private(set) var isDownloadComplete = false
    
    private var activeTasks = [CancelableStorageTask]()
    
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
        cloudGenerator?.save()
        if thereAreUnsavedChanges {
            print("\nsaved\n")
            thereAreUnsavedChanges = false
            pushData()
        } else { print("not saved: Data is actual") }
    }
    func updateData() {
        cloudGenerator?.updateData()
        getData()
    }
    
    private init() {
        if let generator = MainGenerator.generator as? CloudIDGenerator {
            cloudGenerator = generator
        }
        getData()
    }
    
    private func pushData() {
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
                self.delegate?.uploadComplete(with: error)
            }
            activeTasks.append(uploadTask)
            uploadTask.observe(.failure) { _ in
                self.thereAreUnsavedChanges = true
            }
            uploadTask.observe(.progress) { snapshot in
                self.delegate?.uploadProgress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            }
        }
        
    }
    
    private func getData() {
        activeTasks.forEach { $0.cancel() }
        activeTasks.removeAll()
        isDownloadComplete = false
        
        let decoder = JSONDecoder()
        let operationsRef = storageRef.child(Path.operations)
        
        let downloadTask = operationsRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if error == nil, let data = data {
                if let ops = (try? decoder.decode(Ops.self, from: data)) {
                    self.operations = ops.flowOps + ops.debtOps
                    self.thereAreUnsavedChanges = false
                }
            }
            self.isDownloadComplete = true
            self.delegate?.downloadComplete(with: error)
        }
        activeTasks.append(downloadTask)
        downloadTask.observe(.progress) { snapshot in
            self.delegate?.downloadProgress =  Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
        }
    }
}

extension FirebaseDataSource {
    private struct Path {
        static let flowOperationsFile = "flow_operations.json"
        static let debtOperationsFile = "debt_operations.json"
        static let operationsFile = "operations.json"
        
        static var deviceFolder: String {
            return UIDevice.current.identifierForVendor!.uuidString
        }
        static var flowOperations: String {
            return "\(deviceFolder)/\(flowOperationsFile)"
        }
        static var debtOperations: String {
            return "\(deviceFolder)/\(debtOperationsFile)"
        }
        static var operations: String {
            return "\(deviceFolder)/\(operationsFile)"
        }
    }
    
    private struct Ops: Codable {
        var flowOps: [FlowOperation]
        var debtOps: [DebtOperation]
    }
}

protocol CancelableStorageTask {
    func cancel()
}
extension StorageUploadTask: CancelableStorageTask {}
extension StorageDownloadTask: CancelableStorageTask {}


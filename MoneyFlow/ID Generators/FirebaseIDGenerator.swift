//
//  FirebaseIDGenerator.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 28/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation
import Firebase

class FirebaseIDGenerator: CloudIDGenerator {
    
    static let shared = FirebaseIDGenerator()
    
    private let storageRef = Storage.storage().reference()
    private var nextID: Int!
    private var thereAreUnsavedChanges = false
    private var activeTasks = [CancelableStorageTask]()
    
    var delegate: CloudIDGeneratorDelegate?
    var isDownloadComplete: Bool {
        return nextID != nil
    }
    
    func generateID() -> Int {
        thereAreUnsavedChanges = true
        let id = nextID!
        nextID += 1
        return id
    }
    
    func save() {
        if thereAreUnsavedChanges {
//            print("Firebase generator saving")
            pushData()
        }
    }
    
    func updateData() {
        getData()
    }
    
    func cancelLoading() {
        activeTasks.cancelAndRemoveAll()
    }
    
    // call makes nothing but create static instance of this class
    func configure() {}
    
    private init() {
        print("generator init")
        getData()
    }
    
    private func getData() {
        activeTasks.cancelAndRemoveAll()
        
        let decoder = JSONDecoder()
        let operationsRef = storageRef.child(Path.nextID)
        
        let downloadTask = operationsRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if error == nil {
                if let data = data {
                    if let value = (try? decoder.decode(Int.self, from: data)) {
                        self.nextID = value
                    }
                }
                if self.nextID == nil { self.nextID = 0 }
            } else if error!.localizedDescription == Path.doesNotExistError {
                self.nextID = 0
            }
            self.delegate?.generatorDownloadComplete(with: error)
//            print("Firebase generator download complete")
        }
        activeTasks.append(downloadTask)
    }
    
    private func pushData() {
        activeTasks.cancelAndRemoveAll()
        
        let encoder = JSONEncoder()
        let operationsRef = storageRef.child(Path.nextID)
        let metadata = StorageMetadata()
        metadata.contentType = "application/json"
        
        if let data = try? encoder.encode(nextID!) {
            let uploadTask = operationsRef.putData(data, metadata: metadata) { (metadata, error) in
                self.thereAreUnsavedChanges = false
                self.delegate?.generatorUploadComplete(with: error)
//                print("Firebase generator saved successfully")
            }
            activeTasks.append(uploadTask)
        }
    }
    
}

extension FirebaseIDGenerator {
    private struct Path {
        static let nextIDFile = "nextID.json"
        
        static var deviceFolder: String {
            return UIDevice.current.identifierForVendor!.uuidString
        }
        static var nextID: String {
            return "\(deviceFolder)/\(nextIDFile)"
        }
        static var doesNotExistError: String {
            return "Object " + nextID + " does not exist."
        }
    }
}

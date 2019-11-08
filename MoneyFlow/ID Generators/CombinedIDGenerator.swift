//
//  CombinedIDGenerator.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 02/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation
import Firebase

class CombinedIDGenerator: CloudIDGenerator {
    static let shared = CombinedIDGenerator()
    
    private let storageRef = Storage.storage().reference()
    private let defaults = UserDefaults()
    private var nextID: Int!
    private var activeTasks = [CancelableStorageTask]()
    
    var delegate: CloudIDGeneratorDelegate?
    var isDownloadComplete: Bool {
        return nextID != nil
    }
    
    func generateID() -> Int {
        let id = nextID!
        nextID += 1
        saveDataToDefaults()
        return id
    }
    
    func save() {
        saveDataToStorage()
    }
    
    func updateData() {
        getDataFromStorage()
    }
    
    func cancelLoading() {
        activeTasks.cancelAndRemoveAll()
    }
    
    // call makes nothing but create static instance of this class
    func configure() {}
    
    private init() {
        if GlobalConstants.CloudDataSource.isFirstLoad { getDataFromStorage() }
        else {
            getDataFromDefaults()
        }
    }
    
    private func getDataFromDefaults() {
        nextID = defaults.integer(forKey: UserDefaultsKeys.nextID)
    }
    
    private func getDataFromStorage() {
        activeTasks.cancelAndRemoveAll()
        
        let decoder = JSONDecoder()
        let operationsRef = storageRef.child(Path.nextID)
        
        let downloadTask = operationsRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if error == nil, let data = data {
                if let value = (try? decoder.decode(Int.self, from: data)) {
                    self.nextID = value
                }
            }
            if (error != nil && error?.localizedDescription == Path.doesNotExistError) || error == nil {
                if self.nextID == nil { self.nextID = 0 }
                self.saveDataToDefaults()
                self.delegate?.generatorDownloadComplete(with: nil)
                if GlobalConstants.CloudDataSource.isFirstLoad {
                    GlobalConstants.CloudDataSource.firstLoadComplete()
                }
            } else {
                self.delegate?.generatorDownloadComplete(with: error)
            }
            print("Generator's nextID is " + (self.nextID == nil ? "none" : "\(self.nextID!)"))
        }
        activeTasks.append(downloadTask)
    }
    
    private func saveDataToDefaults() {
        defaults.set(nextID, forKey: UserDefaultsKeys.nextID)
    }
    
    private func saveDataToStorage() {
        activeTasks.cancelAndRemoveAll()
        
        let encoder = JSONEncoder()
        let operationsRef = storageRef.child(Path.nextID)
        let metadata = StorageMetadata()
        metadata.contentType = "application/json"
        
        if let data = try? encoder.encode(nextID!) {
            let uploadTask = operationsRef.putData(data, metadata: metadata) { (metadata, error) in
                self.delegate?.generatorUploadComplete(with: error)
                print("Firebase generator saved to storage successfully")
            }
            activeTasks.append(uploadTask)
        }
    }
    
}

extension CombinedIDGenerator {
    private struct Path {
        static let nextIDFile = "nextID.json"
        
        static var userFolder: String {
            //            return UIDevice.current.identifierForVendor!.uuidString
            return Auth.auth().currentUser!.email!
        }
        static var nextID: String {
            return "\(userFolder)/\(nextIDFile)"
        }
        static var doesNotExistError: String {
            return "Object " + nextID + " does not exist."
        }
    }
    
    private struct UserDefaultsKeys {
        static let nextID = "nextID"
    }
}


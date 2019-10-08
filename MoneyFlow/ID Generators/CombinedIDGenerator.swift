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
    
    // call makes nothing but create static instance of this class
    func configure() {}
    
    private init() {
        if AppDelegate.isThisNotFirstLaunch { getDataFromDefaults() }
        else {
            getDataFromStorage()
        }
    }
    
    private func getDataFromDefaults() {
        nextID = defaults.integer(forKey: UserDefaultsKeys.nextID)
    }
    
    private func getDataFromStorage() {
        let decoder = JSONDecoder()
        let operationsRef = storageRef.child(Path.nextID)
        
        operationsRef.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if error == nil, let data = data {
                if let value = (try? decoder.decode(Int.self, from: data)) {
                    self.nextID = value
                }
            } else {
                self.nextID = 0
            }
            self.delegate?.generatorDownloadComplete(with: error)
            print("Firebase generator download complete")
        }
    }
    
    private func saveDataToDefaults() {
        defaults.set(nextID, forKey: UserDefaultsKeys.nextID)
    }
    
    private func saveDataToStorage() {
        let encoder = JSONEncoder()
        let operationsRef = storageRef.child(Path.nextID)
        let metadata = StorageMetadata()
        metadata.contentType = "application/json"
        
        if let data = try? encoder.encode(nextID!) {
            operationsRef.putData(data, metadata: metadata) { (metadata, error) in
                self.delegate?.generatorUploadComplete(with: error)
                print("Firebase generator saved successfully")
            }
        }
    }
    
}

extension CombinedIDGenerator {
    private struct Path {
        static let nextIDFile = "nextID.json"
        
        static var deviceFolder: String {
            return UIDevice.current.identifierForVendor!.uuidString
        }
        static var nextID: String {
            return "\(deviceFolder)/\(nextIDFile)"
        }
    }
    
    private struct UserDefaultsKeys {
        static let nextID = "nextID"
    }
}


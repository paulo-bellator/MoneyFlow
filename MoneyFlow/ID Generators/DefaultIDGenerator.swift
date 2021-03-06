//
//  DefaultIDGenerator.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

class DefaultIDGenerator: IDGenerator {
    
    static let shared = DefaultIDGenerator()
    private var nextID: Int
    private let defaults = UserDefaults()
    
    func generateID() -> Int {
        let id = nextID
        nextID += 1
        defaults.set(nextID, forKey: UserDefaultsKeys.nextID)
        return id
    }

    private init() {
        nextID = defaults.integer(forKey: UserDefaultsKeys.nextID)
    }
    
}

extension DefaultIDGenerator {
    private struct UserDefaultsKeys {
        static let nextID = "nextID"
    }
}

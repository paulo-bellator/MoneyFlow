//
//  IDGenerator.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

protocol IDGenerator {
    func generateID() -> Int
}

class MainGenerator {
    static var generator: IDGenerator = DefaultIDGenerator.shared
}

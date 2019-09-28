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

protocol CloudIDGenerator: IDGenerator {
    var delegate: CloudIDGeneratorDelegate? { get set }
    var isDownloadComplete: Bool { get }
    func updateData()
    func save()
}
protocol CloudIDGeneratorDelegate: class {
    func generatorDownloadComplete(with error: Error?)
    func generatorUploadComplete(with error: Error?)
}

class MainGenerator {
//    static var generator: IDGenerator = DefaultIDGenerator.shared
    static var generator: IDGenerator = FirebaseIDGenerator.shared
}

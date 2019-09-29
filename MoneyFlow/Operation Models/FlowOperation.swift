//
//  Operation.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

class FlowOperation: Operation, Codable
{
    let id: Int
    private(set) var date: Date
    private(set) var value: Double
    private(set) var currency: Currency = .rub
    private(set) var category: String
    private(set) var account: String
    private(set) var comment: String?
    
    init(_ value: Double, for category: String, with account: String) {
        id = MainGenerator.generator.generateID()
        date = Date()
        self.value = value
        self.category = category
        self.account = account
    }
    
    convenience init(date: Date, value: Double, currency: Currency = .rub, category: String, account: String, comment: String? = nil ) {
        self.init(value, for: category, with: account)
        self.currency = currency
        self.comment = comment
        self.date = date
    }
}

extension FlowOperation {
    var description: String {
        var result = "\n"
        result += "ID: \(id)\n"
        result += "Date: \(date.formattedDescription)\n"
        result += "Value: \(value.rounded())\n"
        result += "Currency: \(currency.rawValue)\n"
        result += "Account: \(account)\n"
        result += "Category: \(category)\n"
        result += comment != nil ? "Comment: \(comment!)\n" : ""
        
        return result
    }
}



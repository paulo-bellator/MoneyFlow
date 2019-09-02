//
//  Operation.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

struct FlowOperation
{
    let id: Int
    private(set) var date: Date
    private(set) var value: Double
    private(set) var currency: Currency = .rub
    private(set) var category: String
    private(set) var account: String
    private(set) var comment: String?
    
    init(_ value: Double, for category: String, with account: String) {
        id = Operations.shared.idGenerator()
        date = Date()
        self.value = value
        self.category = category
        self.account = account
    }
    
    init(date: Date, value: Double, currency: Currency = .rub, category: String, account: String, comment: String? = nil ) {
        self.init(value, for: category, with: account)
        self.currency = currency
        self.comment = comment
        self.date = date
    }
    
    var description: String {
        var result = ""
        result += "ID: \(id)\n"
        result += "Date: \(date.description)\n"
        result += "Value: \(value)\n"
        
        return result
    }
}

enum Currency: String {
    case usd = "USD"
    case eur = "EUR"
    case rub = "RUB"
}

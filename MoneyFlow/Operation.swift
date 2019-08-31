//
//  Operation.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

struct Operation
{
    
    var date: Date
    var value: Double
    var currency: String = "RUB"
    var category: String
    var account: String
    var comment: String?
    
    init(_ value: Double, for category: String, by account: String) {
        date = Date()
        self.value = value
        self.category = category
        self.account = account
    }
    
    init(date: Date, value: Double, currency: String = "RUB", category: String, account: String, comment: String? = nil ) {
        self.init(value, for: category, by: account)
        self.currency = currency
        self.comment = comment
    }
    
    
}


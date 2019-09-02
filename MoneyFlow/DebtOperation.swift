//
//  DebtOperation.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

struct DebtOperation
{
    private(set) var date: Date
    private(set) var value: Double
    private(set) var currency: Currency = .rub
    private(set) var person: String
    private(set) var account: String
    private(set) var comment: String?
    
    init(_ value: Double, person: String, with account: String) {
        date = Date()
        self.value = value
        self.person = person
        self.account = account
    }
    
    init(date: Date, value: Double, currency: Currency = .rub, person: String, account: String, comment: String? = nil ) {
        self.init(value, person: person, with: account)
        self.currency = currency
        self.comment = comment
        self.date = date
    }
}

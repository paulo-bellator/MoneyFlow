//
//  DebtOperation.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

class DebtOperation: Operation, Codable
{
    let id: Int
    private(set) var date: Date
    private(set) var value: Double
    private(set) var currency: Currency = .rub
    private(set) var contact: String
    private(set) var account: String
    private(set) var comment: String?
    
    init(_ value: Double, contact: String, with account: String) {
        id = MainGenerator.generator.generateID()
        date = Date()
        self.value = value
        self.contact = contact
        self.account = account
    }
    
    convenience init(date: Date, value: Double, currency: Currency = .rub, contact: String, account: String, comment: String? = nil ) {
        self.init(value, contact: contact, with: account)
        self.currency = currency
        self.comment = comment
        self.date = date
    }
    
}

extension DebtOperation {
    var description: String {
        var result = "\n"
        result += "ID: \(id)\n"
        result += "Date: \(date.formattedDescription)\n"
        result += "Value: \(value.rounded())\n"
        result += "Currency: \(currency.rawValue)\n"
        result += "Account: \(account)\n"
        result += "Contact: \(contact)\n"
        
        return result
    }
}

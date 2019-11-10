//
//  TransferOperation.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 10/11/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

class TransferOperation: Operation, Codable
{
    let id: Int
    var date: Date
    var value: Double
    var currency: Currency = .rub
    var account: String
    var destinationAccount: String
    
    init(_ value: Double, from account: String, to destinationAccount: String) {
        id = MainGenerator.generator.generateID()
        date = Date()
        self.value = value
        self.account = account
        self.destinationAccount = destinationAccount
    }
    
    convenience init(date: Date, value: Double, currency: Currency = .rub, fromAccount: String, toAccount: String) {
        self.init(value, from: fromAccount, to: toAccount)
        self.currency = currency
        self.date = date
    }
}

extension TransferOperation {
    var description: String {
        var result = "\n"
        result += "ID: \(id)\n"
        result += "Date: \(date.formattedDescription)\n"
        result += "Value: \(value.rounded())\n"
        result += "Currency: \(currency.rawValue)\n"
        result += "From account: \(account)\n"
        result += "To account: \(destinationAccount)\n"
        
        return result
    }
}

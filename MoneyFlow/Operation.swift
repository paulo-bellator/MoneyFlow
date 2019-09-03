//
//  Operation.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

protocol Operation: CustomStringConvertible, Codable {
    var id: Int { get }
    var date: Date { get }
    var value: Double { get }
    var currency: Currency { get }
    var account: String { get }
}

extension Operation {
    var description: String {
        var result = "\n"
        result += "ID: \(id)\n"
        result += "Date: \(date.description)\n"
        result += "Value: \(value.rounded())\n"
        result += "Currency: \(currency.rawValue)\n"
        result += "Account: \(account)\n"
        
        return result
    }
}



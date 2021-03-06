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

enum Currency: String, Codable {
    case usd = "$"
    case eur = "€"
    case rub = "₽"
    
    static var all: [Currency] {
        return [.rub, .usd, .eur]
    }
    static var allSignes: [String] {
        return ["₽", "$", "€"]
    }
}

extension Operation {
    var description: String {
        var result = "\n"
        result += "ID: \(id)\n"
        result += "Date: \(date.formattedDescription)\n"
        result += "Value: \(value.currencyFormattedDescription(currency))\n"
        //        result += "Currency: \(currency.rawValue)\n"
        result += "Account: \(account)\n"
        
        return result
    }
}

extension Date {
    var formattedDescription: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: self)
    }
    
    func formatted(in format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension Double {
    func currencyFormattedDescription(_ currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        let formattedNumberString = formatter.string(from: NSNumber(value: Int(self)))
        
        if let numberString = formattedNumberString {
            return numberString + " " + currency.rawValue
        } else {
            return self.description
        }
    }
}




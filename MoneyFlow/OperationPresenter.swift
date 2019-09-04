//
//  OperationPresenter.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 04/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class OperationPresenter {

    private let operation: Operation
    
    private let signForCurrency: [Currency: String] = [.rub: "₽", .eur: "€", .usd: "$"]
    private let emojiForCategory: [String: String] = ["Продукты": "🥦", "Развлечения": "🎮", "Здоровье": "💊", "Проезд": "🚎", "Связь и интернет": "📡"]
    private let defaultEmojiForCategory = "❓"
    private let emojiForContact: [String: String] = ["ООО МояРабота": "🏢", "Вася": "👨‍🍳", "Петя": "🤵", "Тигран": "👳🏻‍♂️"]
    private let defaultEmojiForContact = "❓"

    lazy var idString: String = {
        return operation.id.description
    }()
    
    private(set) var dateString: String?
    
    lazy var valueString: String = {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .decimal
        let formattedNumberString = formatter.string(from: NSNumber(value: Int(operation.value)))
        
        if let numberString = formattedNumberString {
            return numberString + " " + signForCurrency[operation.currency]!
        } else {
            return "error"
        }
    }()
    
    lazy var contactString: String? = {
        if let op = operation as? DebtOperation { return op.contact }
        else { return nil }
    }()
    
    lazy var contactEmoji: String? = {
        if let op = operation as? DebtOperation { return emojiForContact[op.contact] ?? defaultEmojiForContact }
        else { return nil }
    }()
    
    lazy var categoryString: String? = {
        if let op = operation as? FlowOperation { return op.category }
        else { return nil }
    }()
    
    lazy var categoryEmoji: String? = {
        if let op = operation as? FlowOperation { return emojiForCategory[op.category] ?? defaultEmojiForCategory }
        else { return nil }
    }()
    
    lazy var accountString: String = {
        return operation.account
    }()
    
    lazy var commentString: String? = {
//        if let op = operation as? FlowOperation { return op.comment }
//        if let op = operation as? DebtOperation { return op.comment }
//        return nil
        return operation.date.formattedDescription
    }()
    
    init(_ operation: Operation) {
        self.operation = operation
    }
}

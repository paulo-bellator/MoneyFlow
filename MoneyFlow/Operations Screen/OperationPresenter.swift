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
    
    private let emojiForCategory: [String: String] = ["Продукты": "🥦", "Развлечения": "🎮", "Здоровье": "💊", "Проезд": "🚎", "Связь и интернет": "📡"]
    private let defaultEmojiForCategory = "❓"
    private let emojiForContact: [String: String] = ["ООО МояРабота": "🏢", "Вася": "👨‍🍳", "Петя": "🤵", "Тигран": "👳🏻‍♂️"]
    private let defaultEmojiForContact = "❓"

    // temporarly use data placeholder
    
        static let allCategories = ["Продукты", "Развлечения", "Здоровье", "Проезд", "Связь и интернет"]
        static let allContacts = ["ООО МояРабота", "Вася", "Петя", "Тигран"]
        static let allCurrencies = Currency.allSignes
        static let allAccounts = ["Наличные", "Сбербанк МСК", "Альфа", "Хоум Кредит", "Сбербанк РНД"]
    
    // temporarly use data placeholder
    
    lazy var idString: String = {
        return operation.id.description
    }()
    
    lazy var dateString: String = {
        return operation.date.formattedDescription
    }()
    
    lazy var valueString: String = {
        return operation.value.currencyFormattedDescription(operation.currency)
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
        if let op = operation as? FlowOperation { return op.comment }
        if let op = operation as? DebtOperation { return op.comment }
        return nil
//        return dateString
    }()
    
    init(_ operation: Operation) {
        self.operation = operation
    }
}

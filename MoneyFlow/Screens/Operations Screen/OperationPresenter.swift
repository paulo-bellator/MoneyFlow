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
    private let settings = SettingsPresenter.shared
    
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
        if let op = operation as? DebtOperation { return settings.emojiFor(contact: op.contact) }
        else { return nil }
    }()
    
    lazy var categoryString: String? = {
        if let op = operation as? FlowOperation { return op.category }
        else { return nil }
    }()
    
    lazy var categoryEmoji: String? = {
        if let op = operation as? FlowOperation { return settings.emojiFor(category: op.category) }
        else { return nil }
    }()
    
    lazy var accountString: String = {
        return operation.account
    }()
    
    lazy var commentString: String? = {
//        if let op = operation as? FlowOperation { return op.comment }
//        if let op = operation as? DebtOperation { return op.comment }
//        return nil
        return idString + " " + dateString
    }()
    
    init(_ operation: Operation) {
        self.operation = operation
    }
}

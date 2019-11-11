//
//  AccountsPresenter.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 26/10/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

class AccountsPresenter {
    
    private let settings = SettingsPresenter.shared
    private let presenter = Presenter()
    
    private var operations: [Operation] {
        return MainData.source.operations
    }
    
    var accounts: [String] { return settings.enabledAccounts }
    var currencies: [Currency] { settings.enabledCurrencies }
    var currencySignes: [String] { currencies.map({ $0.rawValue }) }
    
    func availableMoney(in currency: Currency) -> Double {
        let operationsWithoutDebtsWithoutAccounts: [Operation] = operations.compactMap { op in
            if let debtOp = op as? DebtOperation, debtOp.account.isEmpty { return nil }
            if op is TransferOperation { return nil }
            return op
        }
        return operationsWithoutDebtsWithoutAccounts.valuesSum(currency)
    }
    
    func totalMoney(in currency: Currency) -> Double {
        let operationsWithoutDebtsWithAccounts: [Operation] = operations.compactMap { op in
            if let debtOp = op as? DebtOperation, !debtOp.account.isEmpty { return nil }
            if op is TransferOperation { return nil }
            return op
        }
        return operationsWithoutDebtsWithAccounts.valuesSum(currency)
    }
    
    func availableMoneyString(in currency: Currency) -> String {
        return availableMoney(in: currency).currencyFormattedDescription(currency)
    }
    func totalMoneyString(in currency: Currency) -> String {
        return totalMoney(in: currency).currencyFormattedDescription(currency)
    }
    
    func oweMe(in currency: Currency) -> Double {
        var result = 0.0
        var contactsBalance = [String: Double]()
        let ops = presenter.filter(flowOperations: false, transferOperations: false, currencies: [currency]) as! [DebtOperation]
        
        for op in ops {
            let value = op.account.isEmpty ? -op.value : op.value
            contactsBalance.sumToCurrentValue(value, for: op.contact)
        }
        let balancesArray = contactsBalance.values
        balancesArray.forEach { if $0 < 0 { result += $0 } }
        
        return abs(result)
    }
    func oweMeString(in currency: Currency) -> String {
        return oweMe(in: currency).currencyFormattedDescription(currency)
    }
    
    func iOwe(in currency: Currency) -> Double {
        var result = 0.0
        var contactsBalance = [String: Double]()
        let ops = presenter.filter(flowOperations: false, transferOperations: false, currencies: [currency]) as! [DebtOperation]
        
        for op in ops {
            let value = op.account.isEmpty ? -op.value : op.value
            contactsBalance.sumToCurrentValue(value, for: op.contact)
        }
        let balancesArray = contactsBalance.values
        balancesArray.forEach { if $0 > 0 { result += $0 } }
        
        return result
    }
    func iOweString(in currency: Currency) -> String {
        return iOwe(in: currency).currencyFormattedDescription(currency)
    }

    
    func moneyAmountByAccounts(in currency: Currency) -> [(account: String, amount: Double)] {
        var result = [(String, Double)]()
        var dictionary = [String: Double]()
        operations.forEach {
            if $0.currency == currency {
                if let transfer = $0 as? TransferOperation {
                    dictionary.sumToCurrentValue(-transfer.value, for: transfer.account)
                    dictionary.sumToCurrentValue(transfer.value, for: transfer.destinationAccount)
                } else {
                    dictionary.sumToCurrentValue($0.value, for: $0.account)
                }
            }
        }
        for account in settings.enabledAccounts {
            if let amount = dictionary[account] {
                result.append((account, amount))
            }
        }
        return result
    }
    
    func formattedMoneyAmountByAccounts(in currency: Currency) -> [(account: String, amount: String)] {
        return moneyAmountByAccounts(in: currency).map { ($0.account, $0.amount.currencyFormattedDescription(currency)) }
    }
    
    func moneyByLenders(in currency: Currency) -> [(contact: String, amount: Double)] {
        var result = [(String, Double)]()
        var dictionary = [String: Double]()
        let debtOperations = presenter.debtOperations()
        
        debtOperations.forEach {
            if $0.currency == currency {
                let value = $0.account.isEmpty ? -$0.value : $0.value
                dictionary.sumToCurrentValue(value, for: $0.contact)
            }
        }
        for contact in settings.enabledContacts {
            if let amount = dictionary[contact] {
                if amount > 0 { result.append((contact, amount)) }
            }
        }
        return result
    }
    
    func formattedMoneyByLenders(in currency: Currency) -> [(contact: String, amount: String)] {
        return moneyByLenders(in: currency).map { ($0.contact, $0.amount.currencyFormattedDescription(currency)) }
    }
    
    func moneyByDebtors(in currency: Currency) -> [(contact: String, amount: Double)] {
        var result = [(String, Double)]()
        var dictionary = [String: Double]()
        let debtOperations = presenter.debtOperations()
        
        debtOperations.forEach {
            if $0.currency == currency {
                let value = $0.account.isEmpty ? -$0.value : $0.value
                dictionary.sumToCurrentValue(value, for: $0.contact)
            }
        }
        for contact in settings.enabledContacts {
            if let amount = dictionary[contact] {
                if amount <= 0 { result.append((contact, abs(amount))) }
            } else {
                result.append((contact, 0.0))
            }
        }
        return result
    }
    
    func formattedMoneyByDebtors(in currency: Currency) -> [(contact: String, amount: String)] {
        return moneyByDebtors(in: currency).map { ($0.contact, $0.amount.currencyFormattedDescription(currency)) }
    }
    
}

extension Dictionary where Key == String, Value == Double {
    mutating func sumToCurrentValue(_ value: Double, for key: String) {
        if self[key] != nil {
            self[key]! += value
        } else {
            self[key] = value
        }
    }
}

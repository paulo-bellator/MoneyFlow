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
            else { return op }
        }
        return operationsWithoutDebtsWithoutAccounts.valuesSum(currency)
    }
    
    func totalMoney(in currency: Currency) -> Double {
        let operationsWithoutDebtsWithAccounts: [Operation] = operations.compactMap { op in
            if let debtOp = op as? DebtOperation, !debtOp.account.isEmpty { return nil }
            else { return op }
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
        let ops = presenter.filter(flowOperations: false, currencies: [currency]) as! [DebtOperation]
        
        for op in ops {
            let value = op.account.isEmpty ? -op.value : op.value
            if contactsBalance[op.contact] != nil {
                contactsBalance[op.contact]! += value
            } else {
                contactsBalance[op.contact] = value
            }
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
        let ops = presenter.filter(flowOperations: false, currencies: [currency]) as! [DebtOperation]
        
        for op in ops {
            let value = op.account.isEmpty ? -op.value : op.value
            if contactsBalance[op.contact] != nil {
                contactsBalance[op.contact]! += value
            } else {
                contactsBalance[op.contact] = value
            }
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
                if dictionary[$0.account] != nil {
                    dictionary[$0.account]! += $0.value
                } else {
                    dictionary[$0.account] = $0.value
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
        let debtOperations = presenter.debtOperations() as! [DebtOperation]
        
        debtOperations.forEach {
            if $0.currency == currency {
                let value = $0.account.isEmpty ? -$0.value : $0.value
                if dictionary[$0.contact] != nil {
                    dictionary[$0.contact]! += value
                } else {
                    dictionary[$0.contact] = value
                }
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
        let debtOperations = presenter.debtOperations() as! [DebtOperation]
        
        debtOperations.forEach {
            if $0.currency == currency {
                let value = $0.account.isEmpty ? -$0.value : $0.value
                if dictionary[$0.contact] != nil {
                    dictionary[$0.contact]! += value
                } else {
                    dictionary[$0.contact] = value
                }
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

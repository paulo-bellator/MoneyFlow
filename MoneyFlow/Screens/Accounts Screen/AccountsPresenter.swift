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
    
    var accounts: [String] { return settings.accounts }
    var currencies: [Currency] { settings.currencies }
    var currencySignes: [String] { currencies.map({ $0.rawValue }) }
    
    func availableMoney(in currency: Currency) -> Double {
        return operations.valuesSum(currency)
    }
    func totalMoney(in currency: Currency) -> Double {
        return presenter.filter(debtOperations: false, flowOperations: true).valuesSum(currency)
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
            if contactsBalance[op.contact] != nil {
                contactsBalance[op.contact]! += op.value
            } else {
                contactsBalance[op.contact] = op.value
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
            if contactsBalance[op.contact] != nil {
                contactsBalance[op.contact]! += op.value
            } else {
                contactsBalance[op.contact] = op.value
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
        for account in settings.accounts {
            if let amount = dictionary[account] {
                result.append((account, amount))
            }
        }
//        for account in settings.accounts {
//            let amount = presenter.filter(accounts: [account]).valuesSum(currency)
//            result.append((account, amount))
//        }
        return result
    }
    
    func formattedMoneyAmountByAccounts(in currency: Currency) -> [(account: String, amount: String)] {
        return moneyAmountByAccounts(in: currency).map { ($0.account, $0.amount.currencyFormattedDescription(currency)) }
    }
    
    
}

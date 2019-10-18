//
//  SummaryPresenter.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 19/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

class SummaryPresenter {
    
    let settings = SettingsPresenter.shared
    private let presenter = Presenter()
    
    private var operations: [Operation] {
        return MainData.source.operations
    }
    
    var operationListIsEmpty: Bool { return operations.isEmpty }
    
    func availableMoney(in currency: Currency, at date: Date? = nil) -> Double {
        return presenter.filter(until: date).valuesSum(currency)
    }
    func totalMoney(in currency: Currency, at date: Date? = nil) -> Double {
        return presenter.filter(until: date, debtOperations: false, flowOperations: true).valuesSum(currency)
    }
    func availableMoneyString(in currency: Currency) -> String {
        return availableMoney(in: currency).currencyFormattedDescription(currency)
    }
    func totalMoneyString(in currency: Currency) -> String {
        return totalMoney(in: currency).currencyFormattedDescription(currency)
    }
    
    func summary(by filterUnit: Presenter.DateFilterUnit, for currency: Currency) -> [(period: DateInterval, availableMoney: Double, totalMoney: Double)] {
        var result = [(period: DateInterval, availableMoney: Double, totalMoney: Double)]()
        let operationsSortedByPeriod = presenter.operationsSorted(by: filterUnit)
        
        for (period, _) in operationsSortedByPeriod {
            let availableMoney = self.availableMoney(in: currency, at: period.end)
            let totalMoney = self.totalMoney(in: currency, at: period.end)
            result.append((period: period, availableMoney: availableMoney, totalMoney: totalMoney))
        }
        return result
    }
    
    func maxAndMinValuesFromSummary(by filterUnit: Presenter.DateFilterUnit, for currency: Currency) -> (max: Double, min: Double) {
        guard !operations.isEmpty else { return (0,0) }
        
        let data = summary(by: filterUnit, for: currency)
        
        var maxValue = data[0].availableMoney
        var minValue = maxValue
        
        data.forEach {
            maxValue = max(maxValue, $0.availableMoney, $0.totalMoney)
            minValue = min(minValue, $0.availableMoney, $0.totalMoney)
        }
        return (maxValue, minValue)
    }
    
    func periodsStringFor(monthFrom date: Date, dateFormat: String? = nil) -> [String] {
        var periodsString = [String]()
        let periods =  periodsFor(monthFrom: date)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = dateFormat ?? "dd MMM"
        
        periods.forEach { periodsString.append(formatter.string(from: $0.end)) }
        return periodsString
    }
    
    func periodsFor(monthFrom date: Date) -> [DateInterval] {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month], from: date)
        let monthNumber = components.month ?? 1
        let yearNumber = components.year
        let numDays = calendar.range(of: .day, in: .month, for: date)!.count
        
        var periodLengths = [Int]()
        
        switch numDays {
        case 28: periodLengths = [7,7,7,7]
        case 29: periodLengths = [8,7,7,7]
        case 30: periodLengths = [8,7,7,8]
        case 31: periodLengths = [8,8,7,8]
        default: periodLengths = [7,7,7,7]
        }
        
        let date1 = calendar.date(from: DateComponents(year: yearNumber, month: monthNumber, day: 1))!
        let date2 = calendar.date(byAdding: .day, value: periodLengths[0], to: date1)! - 1
        
        let date3 = calendar.date(byAdding: .second, value: 1, to: date2)!
        let date4 = calendar.date(byAdding: .day, value: periodLengths[1], to: date3)! - 1
        
        let date5 = calendar.date(byAdding: .second, value: 1, to: date4)!
        let date6 = calendar.date(byAdding: .day, value: periodLengths[2], to: date5)! - 1
        
        let date7 = calendar.date(byAdding: .second, value: 1, to: date6)!
        let date8 = calendar.date(byAdding: .day, value: periodLengths[3], to: date7)! - 1
        
        return [DateInterval(start: date1, end: date2),
                DateInterval(start: date3, end: date4),
                DateInterval(start: date5, end: date6),
                DateInterval(start: date7, end: date8)]
    }
    
    func income(for period: DateInterval?, from categories: [String]? = nil, in currency: Currency) -> Double {
        var resultOps = presenter.filter(since: period?.start, until: period?.end, debtOperations: false, categories: categories)
        resultOps = resultOps.filter { $0.value > 0 }
        return resultOps.valuesSum(currency)
    }
    
    func outcome(for period: DateInterval?, from categories: [String]? = nil, in currency: Currency) -> Double {
        var resultOps = presenter.filter(since: period?.start, until: period?.end, debtOperations: false, categories: categories)
        resultOps = resultOps.filter { $0.value < 0 }
        return resultOps.valuesSum(currency)
    }
    
    func oweMe(for period: DateInterval?, from contacts: [String]? = nil, in currency: Currency) -> Double {
        return oweMe(since: period?.start, until: period?.end, from: contacts, in: currency)
    }
    
    func oweMe(since: Date? = nil, until: Date? = nil, from contacts: [String]? = nil, in currency: Currency) -> Double {
        var result = 0.0
        var contactsBalance = [String: Double]()
        let ops = presenter.filter(
            since: since,
            until: until,
            flowOperations: false,
            currencies: [currency],
            contacts: contacts) as! [DebtOperation]
        
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
    
    
    func iOwe(for period: DateInterval?, from contacts: [String]? = nil, in currency: Currency) -> Double {
        return iOwe(since: period?.start, until: period?.end, from: contacts, in: currency)
    }
    
    func iOwe(since: Date? = nil, until: Date? = nil, from contacts: [String]? = nil, in currency: Currency) -> Double {
        var result = 0.0
        var contactsBalance = [String: Double]()
        let ops = presenter.filter(
            since: since,
            until: until,
            flowOperations: false,
            currencies: [currency],
            contacts: contacts) as! [DebtOperation]
        
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
    
    func incomes(since: Date? = nil, until: Date? = nil, from categories: [String]? = nil, in currency: Currency) -> [Double] {
        let ops = presenter.filter(since: since, until: until, debtOperations: false, currencies: [currency], categories: categories)
        return ops.compactMap { $0.value > 0.0 ? $0.value : nil }
    }
    func outcomes(since: Date? = nil, until: Date? = nil, from categories: [String]? = nil, in currency: Currency) -> [Double] {
        let ops = presenter.filter(since: since, until: until, debtOperations: false, currencies: [currency], categories: categories)
        return ops.compactMap { $0.value < 0.0 ? $0.value : nil }
    }
    
}


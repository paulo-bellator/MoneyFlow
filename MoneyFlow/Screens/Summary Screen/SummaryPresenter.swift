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
    
    func availableMoney(in currency: Currency) -> Double {
        return operations.valuesSum(currency)
    }
    func totalMoney(in currency: Currency) -> Double {
        return operations.filter({ $0 is FlowOperation }).valuesSum(currency)
    }
    func availableMoneyString(in currency: Currency) -> String {
        return availableMoney(in: currency).currencyFormattedDescription(currency)
    }
    func totalMoneyString(in currency: Currency) -> String {
        return totalMoney(in: currency).currencyFormattedDescription(currency)
    }
    
    func summaryByMonth(for currency: Currency) -> [(mounth: String, availableMoney: Double, totalMoney: Double)] {
        var result = [(mounth: String, availableMoney: Double, totalMoney: Double)]()
        let operationsSortedByMonth = presenter.operationsSorted(by: .months)
        
        for (period, ops) in operationsSortedByMonth {
            let availableMoney = ops.valuesSum(currency)
            let totalMoney = ops.filter({ $0 is FlowOperation }).valuesSum(currency)
            result.append((mounth: period, availableMoney: availableMoney, totalMoney: totalMoney))
        }
        return result
    }
    
    func maxAndMinValuesFromSummaryByMonth(for currency: Currency) -> (max: Double, min: Double) {
        let data = summaryByMonth(for: currency)
        
        var maxValue = data[0].availableMoney
        var minValue = maxValue
        
        data.forEach {
            maxValue = max(maxValue, $0.availableMoney, $0.totalMoney)
            minValue = min(minValue, $0.availableMoney, $0.totalMoney)
        }
        return (maxValue, minValue)
    }
    
    func periodsStringFor(month: String, dateFormat: String? = nil) -> [String] {
        var periodsString = [String]()
        let periods =  periodsFor(month: month)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = dateFormat ?? "dd MMM"
        
        periods.forEach { periodsString.append(formatter.string(from: $0.end)) }
        return periodsString
    }
    
    func periodsFor(month: String) -> [DateInterval] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = month.contains(" ") ? "LLLL yyyy" : "LLLL"
        let date = formatter.date(from: month)!
        
        let components = calendar.dateComponents([.year, .month], from: date)
        let monthNumber = components.month ?? 1
        let yearNumber = month.contains(" ") ? components.year : calendar.component(.year, from: Date())
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
        let date2 = calendar.date(byAdding: .day, value: periodLengths[0]-1, to: date1)!
        
        let date3 = calendar.date(byAdding: .day, value: 1, to: date2)!
        let date4 = calendar.date(byAdding: .day, value: periodLengths[1]-1, to: date3)!
        
        let date5 = calendar.date(byAdding: .day, value: 1, to: date4)!
        let date6 = calendar.date(byAdding: .day, value: periodLengths[2]-1, to: date5)!
        
        let date7 = calendar.date(byAdding: .day, value: 1, to: date6)!
        let date8 = calendar.date(byAdding: .day, value: periodLengths[3]-1, to: date7)!
        
        return [DateInterval(start: date1, end: date2),
                DateInterval(start: date3, end: date4),
                DateInterval(start: date5, end: date6),
                DateInterval(start: date7, end: date8)]
    }
    
    
    
    
    
    
    
    
   
}

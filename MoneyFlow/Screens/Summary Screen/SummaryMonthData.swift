//
//  SummaryMonthData.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 26/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class SummaryMonthData {
    
    var monthName: String!
    var availableMoneyAmountFormatted: String!
    var totalMoneyAmountFormatted: String!
    
    var formattedPeriodForWeek: [String] = []
    var formattedResultForWeek: [String] = []
    
    var incomesAmount: String!
    var outcomesAmount: String!
    var debtsBalance: String!
    
    var incomesByWeeks: [ (categoryName: String, values: [String]) ] = []
    var outcomesByWeeks: [ (categoryName: String, values: [String]) ] = []
    var debtsByWeeks: [ (direction: String, values: [String]) ] = []
    
    var incomesByWeeksForChart: [ (categoryName: String, chartSets: [ChartSet]) ] = []
    var outcomesByWeeksForChart: [ (categoryName: String, chartSets: [ChartSet]) ] = []
    var debtsByWeeksForChart: [ (direction: String, chartSets: [ChartSet]) ] = []
    
    private var maxIncome: Double!
    private var maxOutcome: Double!
    private var maxDebt: Double!
    private var boundsForIncomeCategory: [String: (lower: Double, upper: Double)] = [:]
    private var boundsForOutcomeCategory: [String: (lower: Double, upper: Double)] = [:]
    private var boundsForDebtsDirection: [String: (lower: Double, upper: Double)] = [:]
    
    struct ChartSet {
        var value: CGFloat
        var color: UIColor
    }
    
    private func cleanArrays() {
        formattedPeriodForWeek = []
        formattedResultForWeek = []
        incomesByWeeks = []
        outcomesByWeeks = []
        debtsByWeeks = []
        incomesByWeeksForChart = []
        outcomesByWeeksForChart = []
        debtsByWeeksForChart = []
    }
    
    private func setMaximums(source: SummaryPresenter, period: DateInterval, currency: Currency) {
        let summary = source.summary(by: .months, for: currency)
        var allWeeks = [DateInterval]()
        summary.forEach { allWeeks += source.periodsFor(monthFrom: $0.period.end) }
        
        var incomes = [Double]()
        var outcomes = [Double]()
        var debts = [Double]()
        
        var incomesByCategories = [String: [Double]]()
        var outcomesByCategories = [String: [Double]]()
        var debtsByDirection = [String: [Double]]()
        
        for week in allWeeks {
            source.settings.incomeCategories.forEach {
                let income = source.income(for: week, from: [$0], in: currency)
                if income != 0 {
                    incomes.append(income)
                    incomesByCategories[$0] = (incomesByCategories[$0] ?? []) + [income]
                }
            }
            source.settings.outcomeCategories.forEach {
                let outcome = source.outcome(for: week, from: [$0], in: currency)
                if outcome != 0 {
                    outcomes.append(source.outcome(for: week, from: [$0], in: currency))
                    outcomesByCategories[$0] = (outcomesByCategories[$0] ?? []) + [outcome]
                }
            }
            let iOwe = source.iOwe(until: week.end, in: currency)
            if iOwe != 0 {
                debts.append(iOwe)
                debtsByDirection["Я должен"] = (debtsByDirection["Я должен"] ?? []) + [iOwe]
            }
            
            let oweMe = source.oweMe(until: week.end, in: currency)
            if oweMe != 0 {
                debts.append(oweMe)
                debtsByDirection["Мне должны"] = (debtsByDirection["Мне должны"] ?? []) + [oweMe]
            }
        }
        
        let offsetForMaxValueConstant = 0.02
        let maxIncomeIndex = Int(Double(incomes.count - 1) * (1.0 - offsetForMaxValueConstant))
        let maxOutcomeIndex = Int(Double(outcomes.count - 1) * (1.0 - offsetForMaxValueConstant))
        let maxDebtsIndex = Int(Double(debts.count - 1) * (1.0 - offsetForMaxValueConstant/2))
        
        maxIncome = incomes.sorted(by: < )[maxIncomeIndex]
        maxOutcome = outcomes.sorted(by: > )[maxOutcomeIndex]
        maxDebt = debts.sorted(by: < )[maxDebtsIndex]
        
        let lowerBoundsConstant = 0.2
        let upperBoundsConstant = 0.8
        
        incomesByCategories.forEach {
            let values = $1.sorted(by: < )
            let lowerIndex = Int(Double(values.count - 1) * lowerBoundsConstant)
            let upperIndex = Int(Double(values.count - 1) * upperBoundsConstant)
            boundsForIncomeCategory[$0] = (values[lowerIndex], values[upperIndex])
        }
        outcomesByCategories.forEach {
            let values = $1.sorted(by: < )
            let lowerIndex = Int(Double(values.count - 1) * lowerBoundsConstant)
            let upperIndex = Int(Double(values.count - 1) * upperBoundsConstant)
            boundsForOutcomeCategory[$0] = (values[lowerIndex], values[upperIndex])
        }
        debtsByDirection.forEach {
            let values = $1.sorted(by: < )
            let lowerIndex = Int(Double(values.count - 1) * lowerBoundsConstant)
            let upperIndex = Int(Double(values.count - 1) * upperBoundsConstant)
            boundsForDebtsDirection[$0] = (values[lowerIndex], values[upperIndex])
        }
    }
    
    func loadData(source: SummaryPresenter, period: DateInterval, currency: Currency) {
        cleanArrays()
        if maxIncome == nil { setMaximums(source: source, period: period, currency: currency) }
        let weeks = source.periodsFor(monthFrom: period.end)
        
        // data for header
        let month = period.start.formatted(in: "LLLL")
        monthName = month.prefix(1).capitalized + month.dropFirst()
        availableMoneyAmountFormatted = source.availableMoney(in: currency, at: period.end).currencyFormattedDescription(currency)
        totalMoneyAmountFormatted = source.totalMoney(in: currency, at: period.end).currencyFormattedDescription(currency)
        
        for week in weeks {
            formattedPeriodForWeek.append(week.end.formatted(in: "dd MMM"))
            let result = source.totalMoney(in: currency, at: week.end) - source.totalMoney(in: currency, at: week.start)
            formattedResultForWeek.append( (result > 0 ? "+" : "")  + result.shortString )
        }
        
        incomesAmount = source.income(for: period, in: currency).currencyFormattedDescription(currency)
        outcomesAmount = source.outcome(for: period, in: currency).currencyFormattedDescription(currency)
        let iOwe = source.iOwe(until: period.end, in: currency)
        let oweMe = source.oweMe(until: period.end, in: currency)
        debtsBalance = (oweMe - iOwe).currencyFormattedDescription(currency)
        
        // data for tableView with numeric presentation type
        var incomeValues = [[Double]]()
        var outcomeValues = [[Double]]()
        var debtValues = [[Double]]()
        var values = [Double]()
        
        for category in source.settings.incomeCategories {
            values = []
            weeks.forEach { values.append( source.income(for: $0, from: [category], in: currency) ) }
            incomeValues.append(values)
            incomesByWeeks.append( (category, values.map({ $0.shortString })) )
        }
        for category in source.settings.outcomeCategories {
            values = []
            weeks.forEach { values.append( source.outcome(for: $0, from: [category], in: currency) ) }
            outcomeValues.append(values)
            outcomesByWeeks.append( (category, values.map({ $0.shortString })) )
        }
        
        values = []
        weeks.forEach { values.append( source.iOwe(until: $0.end, in: currency) ) }
        debtValues.append(values)
        debtsByWeeks.append( ("Я должен", values.map({ $0.shortString })) )
        
        values = []
        weeks.forEach { values.append( source.oweMe(until: $0.end, in: currency) ) }
        debtValues.append(values)
        debtsByWeeks.append( ("Мне должны", values.map({ $0.shortString })) )
        
        // data for tableView with chart presentation type
        
        for (index, data) in incomesByWeeks.enumerated() {
            var chartSets = [ChartSet]()
            for value in incomeValues[index] {
                let floatValue = CGFloat(value/maxIncome)
//                var color = #colorLiteral(red: 1, green: 0.434411068, blue: 0, alpha: 1)
                var color = Colors.middle
                switch value {
                case 0: color = Colors.zero
                case ..<boundsForIncomeCategory[data.categoryName]!.lower: color = Colors.lower
                case boundsForIncomeCategory[data.categoryName]!.upper...: color = Colors.upper
                default: color = Colors.middle
                }
                chartSets.append(ChartSet(value: floatValue, color: color))
            }
            incomesByWeeksForChart.append( (data.categoryName, chartSets) )
        }
        for (index, data) in outcomesByWeeks.enumerated() {
            var chartSets = [ChartSet]()
            for value in outcomeValues[index] {
                let floatValue = CGFloat(value/maxOutcome)
//                let color = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
                var color = Colors.middle
                switch value {
                case 0: color = Colors.zero
                case ..<boundsForOutcomeCategory[data.categoryName]!.lower: color = Colors.lower
                case boundsForOutcomeCategory[data.categoryName]!.upper...: color = Colors.upper
                default: color = Colors.middle
                }
                chartSets.append(ChartSet(value: floatValue, color: color))
            }
            outcomesByWeeksForChart.append( (data.categoryName, chartSets) )
        }
        for (index, data) in debtsByWeeks.enumerated() {
            var chartSets = [ChartSet]()
            for value in debtValues[index] {
                let floatValue = CGFloat(value/maxDebt)
//                let color = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                var color = Colors.middle
                switch value {
                case 0: color = Colors.zero
                case ..<boundsForDebtsDirection[data.direction]!.lower: color = (index == 0 ? Colors.upper : Colors.lower)
                case boundsForDebtsDirection[data.direction]!.upper...: color = (index == 0 ? Colors.lower : Colors.upper)
                default: color = Colors.middle
                }
                chartSets.append(ChartSet(value: floatValue, color: color))
            }
            debtsByWeeksForChart.append( (data.direction, chartSets) )
        }
    }
}

private struct Colors {
    static let lower = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
    static let middle = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
    static let upper = #colorLiteral(red: 0.3359866122, green: 0.73046875, blue: 0.4521239214, alpha: 1)
    static let zero = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
}

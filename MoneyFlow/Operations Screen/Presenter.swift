//
//  Presenter.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 03/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation

class Presenter {
    
    private var operations: [Operation] {
        return MainData.source.operations
    }
    
    func add(operation: Operation) {
        MainData.source.add(operation: operation)
    }
    func removeOperationWith(identifier: Int) {
        MainData.source.removeOperation(with: identifier)
    }
    func syncronize() {
        MainData.source.save()
    }
    
    /// Return all operations in given boundaries (included)
    func all(since: Date? = nil, until: Date? = nil) -> [Operation] {
        return filter(since: since, until: until)
    }
    
    /// Return debt operations operations in given boundaries (included)
    func debtOperations(since: Date? = nil, until: Date? = nil) -> [Operation] {
        return filter(since: since, until: until, debtOperations: true, flowOperations: false)
    }
    
    /// Return flow operations in given boundaries (included)
    func flowOperations(since: Date? = nil, until: Date? = nil) -> [Operation] {
        return filter(since: since, until: until, debtOperations: false, flowOperations: true)
    }
    
    
    
    //    func change(value: Double, forIdentifier identifier: Int) {
    //        for var operation in operations {
    //            if operation.id == identifier {
    //                operation.value = value
    //            }
    //        }
    //    }
    
    func filter(since: Date? = nil, until: Date? = nil, debtOperations: Bool = true, flowOperations: Bool = true, currencies: [Currency]? = nil, categories: [String]? = nil, contacts: [String]? = nil, accounts: [String]? = nil) -> [Operation] {
        var result = operations
        if let startDate = since {
            result = result.filter { $0.date >= startDate }
        }
        if let endDate = until {
            result = result.filter { $0.date <= endDate }
        }
        if !debtOperations { result = result.filter { !($0 is DebtOperation) } }
        if !flowOperations { result = result.filter { !($0 is FlowOperation) } }
        if let requiredCurrencies = currencies {
            result = result.filter { requiredCurrencies.contains($0.currency) }
        }
        if let requiredAccounts = accounts {
            result = result.filter { requiredAccounts.contains($0.account) }
        }
        if let requiredCategories = categories {
            result = result.filter { ($0 is FlowOperation) && requiredCategories.contains(($0 as! FlowOperation).category) }
        }
        if let requiredContacts = contacts {
            result = result.filter { ($0 is DebtOperation) && requiredContacts.contains(($0 as! DebtOperation).contact) }
        }
        return result
    }
    
    /// Return the array of tuples, containg period and array [Operation] included in period. Can't handle dates after now
    func operationsSorted2(by period: DateFilterUnit) -> [(formattedPeriod: String, ops: [Operation])] {
        var result = [ ( String, [Operation] ) ]()
        
        var tempOperations = operations.sorted { $0.date > $1.date }
        var operationsForPeriod = [Operation]()
        var formattedPeriod = ""
        let calendar = Calendar.current
        
        var components: DateComponents
        switch period {
        case .days: components = calendar.dateComponents([.day, .month, .year], from: Date())
        case .months: components = calendar.dateComponents([.month, .year], from: Date())
        }
        var minimumDate = calendar.date(from: components)!
        
        while !tempOperations.isEmpty {
            while !tempOperations.isEmpty && tempOperations.first!.date >= minimumDate {
                operationsForPeriod.append(tempOperations.removeFirst())
            }
            formattedPeriod = formatted(date: minimumDate, forFilterUnit: period)
            result.append((formattedPeriod, operationsForPeriod))
            switch period {
            case .days: components.day! -= 1
            case .months: components.month! -= 1
            }
            minimumDate = calendar.date(from: components)!
            operationsForPeriod = []
        }
        return result
    }
    
    /// Return the array of tuples, containg period and array [Operation] included in period
    func operationsSorted(by period: DateFilterUnit) -> [(formattedPeriod: String, ops: [Operation])] {
        var result = [ ( String, [Operation] ) ]()
        
        var tempOperations = operations.sorted { $0.date > $1.date }
        var operationsForPeriod = [Operation]()
        var formattedPeriod = ""
        
        let calendar = Calendar.current
        var currentComponents: DateComponents
        var date: Date
        var currentComponentValue: Int
        
        while !tempOperations.isEmpty {
            date = tempOperations.first!.date
            currentComponents = calendar.dateComponents([.day, .month, .year], from: date)
            currentComponentValue = period == .days ? currentComponents.day! : currentComponents.month!
            
            while !tempOperations.isEmpty {
                let components = calendar.dateComponents([.day, .month], from: tempOperations.first!.date)
                let componentValue = period == .days ? components.day! : components.month!
                
                if componentValue == currentComponentValue {
                    operationsForPeriod.append(tempOperations.removeFirst())
                } else {
                    break
                }
            }
            formattedPeriod = formatted(date: date, forFilterUnit: period)
            result.append((formattedPeriod, operationsForPeriod))
            operationsForPeriod = []
        }
        return result
    }
    
    
    /// Return formatted string representation of Date depending on filterUnit
    private func formatted(date: Date, forFilterUnit unit: DateFilterUnit) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        
        if date > Date() {
            formatter.dateFormat = unit == .days ? "dd MMMM yyyy" : "LLLL yyyy"
        } else {
            let calendar = Calendar.current
            let componentsOfDate = calendar.dateComponents([.day, .month, .year], from: date)
            let componentsOfNow = calendar.dateComponents([.day, .month, .year], from: Date())
            let interval = DateInterval.init(start: date, end: Date())
            
            switch unit {
            case .days:
                switch interval.duration {
                case let duration where duration < 24*60*60 && componentsOfNow.day == componentsOfDate.day:
                    return "Сегодня"
                case let duration where duration < 2*24*60*60 && (componentsOfNow.day ?? 0)-1 == componentsOfDate.day:
                    return "Вчера"
                case let duration where duration < 7*24*60*60:
                    formatter.dateFormat = "EEEE, dd MMMM"
                case let duration where duration > 7*24*60*60 && componentsOfNow.year == componentsOfDate.year:
                    formatter.dateFormat = "dd MMMM"
                default:
                    formatter.dateFormat = "dd MMMM yyyy"
                }
            case .months:
                if componentsOfNow.year == componentsOfDate.year { formatter.dateFormat = "LLLL" }
                else { formatter.dateFormat = "LLLL yyyy" }
            }
        }
        var result = formatter.string(from: date)
        result = result.prefix(1).capitalized + result.dropFirst()
        return result
    }
    
    
    enum DateFilterUnit {
        case days, months
    }
}

extension Array where Element == Operation {
    func valuesSum(_ currency: Currency? = nil) -> Double {
        var result = 0.0
        if let cur = currency {
            self.forEach { if $0.currency == cur  { result += $0.value } }
        } else {
            self.forEach { result += $0.value }
        }
        return result
    }
    
}

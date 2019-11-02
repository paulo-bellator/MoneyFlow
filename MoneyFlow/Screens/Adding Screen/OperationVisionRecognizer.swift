//
//  OperationVisionRecognizer.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 29/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import Foundation
import Firebase

class OperationVisionRecognizer {
    
    private var recognizer: VisionTextRecognizer!
    private lazy var vision = Vision.vision()
    
    func recognize(from image: UIImage, completion: @escaping ([Operation]?, Error?) -> Void) {
        let visionImage = VisionImage(image: image)
        
        recognizer.process(visionImage) { recognizerData, error in
            guard error == nil, let data = recognizerData else {
                completion(nil, error)
                return
            }
            
            let account = self.accountDefiner(from: data)
            print(account)
            
            var ops = [Operation]()
            switch account {
            case .sberbank: ops = self.sberbankParser(from: data)
            case .homeCredit: ops = self.homeCreditParser(from: data)
            case .none: break
            }
            completion(ops, error)
        }

    }
    
    
    // MARK: Initialization
    
    init() {
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["en", "ru"]
        recognizer = vision.cloudTextRecognizer(options: options)
    }
    
    
    // MARK: HomeCredit
    
    private func homeCreditParser(from visionText: VisionText) -> [Operation] {
        var operations = [Operation]()
        
        let lines = sortByLines(visionText: visionText)
        debugPrint(lines: lines)
        debugPrintRecognizedObjects(lines: lines, for: .homeCredit)
        
        var rawOperations = [ (date: Date, category: String, comment: String, value: Double) ]()
        var currentDate: Date?
        
        for (index, var line) in lines.enumerated() {
            if let date = dateFromHomeCredit(line[0].text) {
                currentDate = date
                continue
            }
            if line.count < 2 { continue }
            if let value = valueFromHomeCredit(line.last!.text), var date = currentDate {
                if line.count > 1 { line.removeLast() }
                let subject = line.map({$0.text}).joined(separator: " ").replacingOccurrences(of: "\n", with: " ")
                var category = ""
                if index + 1 < lines.count {
                    if lines[index + 1].count < 2 { category = lines[index + 1].first!.text }
                }
                if index + 2 < lines.count {
                    if let time = timeFrom(string: lines[index + 2].first?.text ?? "") {
                        date = date.withTime(hours: time.hours, minutes: time.minutes) ?? date
                    }
                }
                rawOperations.append((date, category, subject, value))
            }
        }
        
        for op in rawOperations {
            let operation = FlowOperation(date: op.date, value: op.value, currency: .rub, category: op.category, account: Accounts.homeCredit, comment: op.comment)
            operations.append(operation)
        }
        
        return operations
    }
    
    private func valueFromHomeCredit(_ string: String) -> Double? {
        guard string.contains("Р") || string.contains("P") || string.contains("₽") else {
            return nil
        }
        
        let sign = string.contains("-") ? "-" : "+"
        let numericString = string.filter { "0123456789,".contains($0) }
        
        var valueString = numericString
        if valueString.count > 3 {
            let range = valueString.index(valueString.endIndex, offsetBy: -3)..<valueString.endIndex
            valueString = valueString.replacingOccurrences(of: ",", with: ".", options: [], range: range).filter { !",".contains($0) }
        }
        let resultString = sign + valueString
        return Double(resultString)
    }
    
    private func dateFromHomeCredit(_ string: String) -> Date? {
        if string.contains("-") { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM"
        var date = formatter.date(from: string)
        if date == nil && string == "Сегодня" { date = Date() }
        if date == nil && string == "Вчера" { date = Date() - 60*60*24 }
        
        if let date = date {
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: Date())
            return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))
            
        } else { return nil }
    }
    
    private func timeFrom(string: String) -> (hours: Int, minutes: Int)? {
        var stringWithoutSpacings = string.replacingOccurrences(of: " " , with: "")
        guard stringWithoutSpacings.count == 5 && stringWithoutSpacings.contains(":") else { return nil }
        
        let hours = Int(stringWithoutSpacings[..<stringWithoutSpacings.firstIndex(of: ":")!])
        stringWithoutSpacings.removeFirst(3)
        let minutes = Int(stringWithoutSpacings)
        
        if let hours = hours, let minutes = minutes {
            return (hours, minutes)
        } else {
            return nil
        }
    }
    
    
    // MARK: Sberbank
    
    private func sberbankParser(from visionText: VisionText) -> [Operation]  {
        var operations = [Operation]()
        
        let lines = sortByLines(visionText: visionText)
        debugPrint(lines: lines)
        debugPrintRecognizedObjects(lines: lines, for: .sberbank)
        
        var rawOperations = [ (date: Date, category: String, comment: String, value: Double) ]()
        var currentDate: Date?
        
        for (index, var line) in lines.enumerated() {
            if let date = dateFromSberbank(line[0].text) {
                currentDate = date
                continue
            }
            if var value = valueFromSberbank(line.last!.text), let date = currentDate {
                if line.count > 1 { line.removeLast() }
                if line.first!.text.count < 3 { line.removeFirst() }
                let subject = line.map({$0.text}).joined(separator: " ").replacingOccurrences(of: "\n", with: " ")
                var category = ""
                if index + 1 < lines.count {
                    if lines[index + 1].count < 3 { category = lines[index + 1].first!.text }
                }
                if category.contains("Входящий перевод") && category.contains("Внесение")  { value = abs(value) }
                rawOperations.append((date, category, subject, value))
            }
        }
        
        for op in rawOperations {
            let operation = FlowOperation(date: op.date, value: op.value, currency: .rub, category: op.category, account: Accounts.sberbank, comment: op.comment)
            operations.append(operation)
        }
        
        return operations
    }
    
   
    private func valueFromSberbank(_ string: String) -> Double? {
        guard string.contains("Р") || string.contains("P") || string.contains("₽") else {
            return nil
        }
        
        let sign = string.contains("+") ? "" : "-"
        let numericString = string.filter { "0123456789,".contains($0) }
        
        var valueString = numericString
        if valueString.count > 3 {
            let range = valueString.index(valueString.endIndex, offsetBy: -3)..<valueString.endIndex
            valueString = valueString.replacingOccurrences(of: ",", with: ".", options: [], range: range).filter { !",".contains($0) }
        }
        let resultString = sign + valueString
        return Double(resultString)
    }
    
    
    private func dateFromSberbank(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM, EE"
        var date = formatter.date(from: string)
        if date == nil && string == "Сегодня" { date = Date() }
        if date == nil && string == "Вчера" { date = Date() - 60*60*24 }
        
        if let date = date {
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: Date())
            return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))
           
        } else { return nil }
    }
    
    
    // MARK: Supporting functions
    
    private func accountDefiner(from visionText: VisionText) -> RecognizingAccount {
           guard visionText.blocks.count > 5 else { return .none }
           if visionText.blocks.last!.text.contains("На карте") {
               let count = visionText.blocks.count
               if visionText.blocks[count - 2].text.contains("История") && visionText.blocks[count - 3].text.contains("Диалоги") {
                   return .sberbank
               }
           }
           
           if visionText.blocks[3].text.contains("Закрыть") {
               if visionText.blocks[4].text.contains("Операции") {
                   return .homeCredit
               }
           }
           
           return .sberbank
       }
       
       private func debugPrint(lines: [[VisionTextBlock]]) {
           for line in lines {
               var text = ""
               for block in line {
                   let string = block.text.replacingOccurrences(of: "\n", with: " ")
                   text += string + "(\(block.frame.minY):\(block.frame.maxY)) | "
               }
               text.removeLast()
               print(text)
           }
       }
       
    private func debugPrintRecognizedObjects(lines: [[VisionTextBlock]], for acc: RecognizingAccount) {
        switch acc {
        case .homeCredit:
            for line in lines {
                for block in line {
                    if let date = dateFromHomeCredit(block.text) {
                        print("HomeCredit: Date: \(date.formattedDescription)")
                    }
                    if let value = valueFromHomeCredit(block.text) {
                        print("HomeCredit: Value: \(value.currencyFormattedDescription(.rub))")
                    }
                    if let time = timeFrom(string: block.text) {
                        print("HomeCredit: Time: \(time.hours):\(time.minutes)")
                    }
                }
            }
        case .sberbank:
            for line in lines {
                if let date = dateFromSberbank(line[0].text) {
                    print("Sberbank: Date: " + date.formattedDescription)
                }
                if let value = valueFromSberbank(line.last!.text) {
                    print("Sberbank: Value: " + value.currencyFormattedDescription(.rub))
                }
            }
        case .none: break
        }
    }
       
       private func sortByLines(visionText: VisionText) -> [[VisionTextBlock]] {
           var lines = [[VisionTextBlock]]()
           
           for block in visionText.blocks {
               if lines.isEmpty { lines.append([block]); continue }
               for (index, line) in lines.enumerated() {
                   if abs(line[0].frame.minY - block.frame.minY) < 15.0 {
                       lines[index].append(block)
                   } else if index == lines.count - 1 {
                       lines.append([block])
                   }
               }
           }
           
           for (index, line) in lines.enumerated() {
               lines[index] = line.sorted { $0.frame.minX < $1.frame.minX }
           }
           
           return lines
       }
    
    private let debugHomeCreditVisionText = ""
}


private struct Accounts {
       private static let defaultSberbankAccount = "Сбербанк"
       private static let defaultHomeCreditAccount = "Хоум кредит"
       private static var accounts = SettingsPresenter.shared.enabledAccountsSorted
       
       static var sberbank: String {
           for account in accounts {
               if account.contains(defaultSberbankAccount) || account.contains(defaultSberbankAccount.lowercased()) {
                   return account
               }
           }
           return defaultSberbankAccount
       }
       
       static var homeCredit: String {
           for account in accounts {
               if account.contains(defaultHomeCreditAccount) || account.contains(defaultHomeCreditAccount.lowercased()) {
                   return account
               }
           }
           return defaultHomeCreditAccount
       }
   }

private enum RecognizingAccount {
    case sberbank, homeCredit, none
}

private extension Date {
    func withTime(hours: Int, minutes: Int) -> Date? {
        let calendar = Calendar.current
        let dateWithDefinedTime = calendar.date(bySettingHour: hours, minute: minutes, second: 0, of: self)
        return dateWithDefinedTime
    }
}



//
//  TestViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 13/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit
import Firebase

class TestViewController: UIViewController {
    
    
    private lazy var recognizer = OperationVisionRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "sberbank_ops_screen")!
        let _ = recognizer.recognize(from: image)
    }
    
}

class OperationVisionRecognizer {
    
    private var recognizer: VisionTextRecognizer!
    private lazy var vision = Vision.vision()
    
    
    func recognize(from image: UIImage) -> (operations: [Operation]?, error: Error?) {
        var ops = [Operation]()
        var resultError: Error?
        var result: VisionText?
        let visionImage = VisionImage(image: image)
        
        recognizer.process(visionImage) { recognizerData, error in
          guard error == nil, let data = recognizerData else {
            resultError = error
            return
          }
            result = data
            ops = self.sberbankParser(from: data)
        }
        
        if let error = resultError {
            return (nil, error)
        } else {
//            ops = sberbankParser(from: result!)
        }
        
        return (ops, resultError)
    }
    
    private func sberbankParser(from visionText: VisionText) -> [Operation]  {
        var ops = [Operation]()
        
        var lines = [[VisionTextBlock]]()
        
        for block in visionText.blocks {
            if lines.isEmpty { lines.append([block]); continue }
            for (index, line) in lines.enumerated() {
                if (abs(line[0].frame.minY - block.frame.minY) < 50.0
                    || abs(line[0].frame.minY - block.frame.maxY) < 30.0
                    || abs(line[0].frame.maxY - block.frame.minY) < 30.0) {
                    lines[index].append(block)
                } else if index == lines.count - 1 {
                    lines.append([block])
                }
            }
        }
        
        for (index, line) in lines.enumerated() {
            lines[index] = line.sorted { $0.frame.minX < $1.frame.minX }
        }
        
        for line in lines {
            var text = ""
            for block in line {
                let string = block.text.replacingOccurrences(of: "\n", with: " ")
                text += string + " | "
            }
            text.removeLast()
            print(text)
        }
        
        for line in lines {
            if let date = dateFromSberbank(line[0].text) {
                print(date.formattedDescription)
            }
            if let value = valueFromSberbank(line.last!.text) {
                print(value.currencyFormattedDescription(.rub))
            }
        }
        
        var rawOps = [ (Date, String, String, Double) ]()
        
        var currentDate: Date?
        for (index, var line) in lines.enumerated() {
            if let date = dateFromSberbank(line[0].text) {
                currentDate = date
                continue
            }
            if let value = valueFromSberbank(line.last!.text), let date = currentDate {
                line.removeLast()
                if line.first!.text.count < 3 { line.removeFirst() }
                let subject = line.map({$0.text}).joined(separator: " ").replacingOccurrences(of: "\n", with: " ")
                var category = ""
                if index+1 < lines.count {
                    if lines[index+1].count < 3 { category = lines[index+1].first!.text }
                }
                rawOps.append((date, category, subject, value))
            }
        }
        
        print("\n")
        rawOps.forEach { print($0) }
        
        return ops
    }
    
    func valueFromSberbank(_ string: String) -> Double? {
        guard string.contains("Р") || string.contains("P") else {
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
        
        if let date = formatter.date(from: string) {
            let calendar = Calendar.current
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: Date())
            return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))
           
        } else { return nil }
    }
    
    init() {
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["en", "ru"]
//        recognizer = vision.onDeviceTextRecognizer()
        recognizer = vision.cloudTextRecognizer(options: options)
    }
}


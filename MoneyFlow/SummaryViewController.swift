//
//  ViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController {
    
    private let presenter = Presenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if Operations.shared.all().isEmpty {
        
            let currencies = [Currency.eur, .rub, .usd]
            let categories = ["Продукты", "Развлечения", "Здоровье", "Проезд", "Связь и интернет"]
            let accounts = ["Наличные", "Сбербанк МСК", "Альфа", "Хоум Кредит", "Сбербанк РНД"]
            for _ in 1...1250 {
                let operation = FlowOperation(date: Date(), value: Double.random(in: -17894...17894), currency: currencies.randomElement()!, category: categories.randomElement()!, account: accounts.randomElement()!)
                presenter.add(operation: operation)
            }
            var sum = 0.0
            for op in presenter.all() {
                sum += op.value
            }
            
            
            print(presenter.filter(currencies: [.usd], categories: ["Продукты", "Проезд"], accounts: ["Альфа", "Наличные"]))
            print("\n\(sum)")
            
//        }
        
        
    }


}


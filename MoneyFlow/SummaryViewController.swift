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
        
        var sum = 0.0
        for op in presenter.all() { sum += op.value }
        
        print(presenter.all())
        //            print(presenter.filter(currencies: [.usd], categories: ["Продукты", "Проезд"], accounts: ["Альфа", "Наличные"]))
        print("\n\(presenter.all().count)")
        print("\n\(sum.rounded())")
        
        presenter.syncronize()
    }


}


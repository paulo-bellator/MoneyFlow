//
//  ViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let presenter = Presenter()

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.all().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let operation = presenter.all()[indexPath.row]
        let cell = UITableViewCell(style: .value2, reuseIdentifier: "testReuseIdentifier")
        cell.textLabel?.text = operation.value.rounded().description
        cell.detailTextLabel?.text = " - " + operation.currency.rawValue + ",  " + operation.account + "  (id: " + operation.id.description + ")"
        
        cell.textLabel?.textColor = operation.value < 0 ? #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1) : #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        var sum = 0.0
        for op in presenter.all() { sum += op.value }
        
        print(presenter.all())
        //            print(presenter.filter(currencies: [.usd], categories: ["Продукты", "Проезд"], accounts: ["Альфа", "Наличные"]))
        print("\n\(presenter.all().count)")
        print("\n\(sum.rounded())")
        
        presenter.syncronize()
    }


}


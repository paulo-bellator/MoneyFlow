//
//  ViewController.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit

class OperationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var talbeViewTopSafeAreaTopConstrain: NSLayoutConstraint!
    
    let operationTableViewCellIdentifier = "OperationCell"
    let operationsHeaderTableViewCellIdentifier = "HeaderCell"
    let filterCollectionViewCellIdentifier = "filterCell"
    var mainCurrency: Currency = .rub
    
    let presenter = Presenter()
    lazy var operationsByDays = presenter.operationsSorted(by: .days)
    var tableViewScrollOffset: CGFloat = 0
    
    var appliedFilterCells = [IndexPath(row: 0, section: 0)] {
        didSet { applyFilter()  }
    }
    
    lazy var arrayOfAllFilterUnits: [FilterUnit] = {
        var result = [FilterUnit]()
        
        result.append(FilterUnit.all("Все"))
        for cur in OperationPresenter.allCurrencies { result.append(FilterUnit.currency(cur)) }
        for acc in OperationPresenter.allAccounts { result.append(FilterUnit.account(acc)) }
        for cat in OperationPresenter.allCategories { result.append(FilterUnit.category(cat)) }
        for con in OperationPresenter.allContacts { result.append(FilterUnit.contact(con)) }
        
        return result
    }()

    
    
    func applyFilter() {
        if appliedFilterCells.count == 1 {
            let filterUnit = arrayOfAllFilterUnits[appliedFilterCells.first!.row]
            switch filterUnit {
            case .all:
                operationsByDays = presenter.operationsSorted(by: .days)
                mainCurrency = .rub
                tableView.reloadData()
                return
            default: break
            }
        }
        var requiredCurrencies = [Currency]()
        var requiredAccounts = [String]()
        var requiredCategories = [String]()
        var requiredContacts = [String]()
        
        for indexPath in appliedFilterCells {
            let filterUnit = arrayOfAllFilterUnits[indexPath.row]
            switch filterUnit {
            case .all: break
            case .account(let value): requiredAccounts.append(value)
            case .category(let value): requiredCategories.append(value)
            case .currency(let value): requiredCurrencies.append(Currency(rawValue: value)!)
            case .contact(let value): requiredContacts.append(value)
            }
        }
        
        let filteredOperation = presenter.filter(currencies: requiredCurrencies, categories: requiredCategories, contacts: requiredContacts, accounts: requiredAccounts)
        operationsByDays = presenter.operationsSorted(by: .days, operations: filteredOperation)
        
        switch requiredCurrencies.count {
        case 1: mainCurrency = requiredCurrencies.first!
        case 2:
            if requiredCurrencies.contains(.rub) { mainCurrency = .rub; break }
            if requiredCurrencies.contains(.usd) { mainCurrency = .usd; break }
            mainCurrency = .eur
        default: mainCurrency = .rub
        }
        
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.sectionHeaderHeight = 35
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 2, left: 7, bottom: 2, right: 7)
    }
    

}

enum FilterUnit {
    case all(String)
    case currency(String)
    case category(String)
    case contact(String)
    case account(String)
    
    var value: String {
        switch self {
        case .all(let value): return value
        case .account(let value): return value
        case .category(let value): return value
        case .currency(let value): return value
        case .contact(let value): return value
        }
    }
}

